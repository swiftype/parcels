require 'parcels/widget_tree'

module Parcels
  class Environment
    attr_reader :sprockets_environment

    delegate :root, :to => :sprockets_environment

    def initialize(sprockets_environment)
      @sprockets_environment = sprockets_environment
      @widget_trees = [ ]
      @workaround_directories_for_widget_trees = { }
      @workaround_directories_root = nil

      register_engines!
    end

    def is_underneath_root?(filename)
      filename = File.expand_path(filename)
      filename.length > root.length && filename[0..(root.length - 1)] == root
    end

    def add_widget_tree!(widget_tree_root)
      widget_tree_root = File.expand_path(widget_tree_root, root)
      widget_tree = widget_trees.detect { |wt| wt.root == widget_tree_root }

      if (! widget_tree)
        widget_tree = WidgetTree.new(self, widget_tree_root)
        widget_trees << widget_tree
      end

      widget_tree.add_workaround_directory_to_sprockets!(sprockets_environment)
      widget_tree.ensure_workaround_directory_is_set_up_during_init!
    end

    def widget_class_from_file(full_path)
      widget_trees.each do |widget_tree|
        if (removed = widget_tree.remove_workaround_directory_from(full_path))
          full_path = removed
          break
        end
      end

      ::Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => widget_trees.map(&:widget_naming_root_dirs).flatten.uniq)
    end

    def create_and_add_all_workaround_directories!
      # widget_trees.each do |widget_tree|
      #   widget_tree.add_workaround_directory_to_sprockets!(sprockets_environment)
      # end
    end

    def add_all_widgets_to!(sprockets_context, set_names)
      if widget_trees.length == 0
        raise %{Error: You have not defined any widget trees -- directories containing Fortitude widgets.
You must call #add_widget_tree! on the Parcels environment, which usually is accessible
as #parcels from your Sprockets environment.}
      end

      widget_trees.each { |wt| wt.add_all_widgets_to_sprockets_context!(sprockets_context, set_names) }
    end

    def workaround_directory_root_for_widget_tree(widget_tree)
      @workaround_directories_for_widget_trees[widget_tree] ||= begin
        if @workaround_directories_root
          File.join(@workaround_directories_root, workaround_directory_name_for(widget_tree))
        else
          File.join(widget_tree.root, PARCELS_WORKAROUND_DIRECTORY_NAME)
        end
      end
    end

    def workaround_directories_root
      @workaround_directories_root
    end

    def workaround_directories_root=(new_root)
      new_root = File.expand_path(new_root)

      if @workaround_directories_for_widget_trees.size > 0 && @workaround_directories_root != new_root
        raise "You can't set the workaround directories root to:
#{new_root}
...it's already set to:
#{@workaround_directories_root}"
      end

      @workaround_directories_root = new_root
    end

    private
    attr_reader :widget_trees

    PARCELS_WORKAROUND_DIRECTORY_NAME = ".parcels_sprockets_workaround".freeze

    def workaround_directory_name_for(widget_tree)
      require 'digest/md5'
      digest = Digest::MD5.hexdigest(widget_tree.root).strip
      "#{PARCELS_WORKAROUND_DIRECTORY_NAME}_#{digest}"
    end

    def register_engines!
      @engines_registered ||= begin
        if ::Parcels.fortitude_available?
          @sprockets_environment.register_engine '.rb', ::Parcels::Fortitude::WidgetEngine
          @sprockets_environment.register_engine '.pcss', ::Parcels::Fortitude::AlongsideEngine
        end
        true
      end
    end
  end
end
