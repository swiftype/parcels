require 'parcels/widget_tree'

module Parcels
  class Environment
    attr_reader :sprockets_environment

    delegate :root, :to => :sprockets_environment

    def initialize(sprockets_environment)
      @sprockets_environment = sprockets_environment
      @widget_trees = [ ]

      register_engines!
    end

    def is_underneath_root?(filename)
      filename = File.expand_path(filename)
      filename.length > root.length && filename[0..(root.length - 1)] == root
    end

    def add_widget_tree!(widget_tree_root)
      widget_tree_root = File.expand_path(widget_tree_root, root)
      unless widget_trees.detect { |wt| wt.root == widget_tree_root }
        widget_trees << WidgetTree.new(self, widget_tree_root)
      end
    end

    def widget_class_from_file(pathname)
      ::Fortitude::Widget.widget_class_from_file(pathname, :root_dirs => widget_trees.map(&:root))
    end

    def create_and_add_all_workaround_directories!
      widget_trees.each do |widget_tree|
        widget_tree.add_workaround_directory_to_sprockets!(sprockets_environment)
      end
    end

    def add_all_widgets_to!(sprockets_context, set_names)
      widget_trees.each { |wt| wt.add_all_widgets_to_sprockets_context!(sprockets_context, set_names) }
    end

    private
    attr_reader :widget_trees

    def register_engines!
      @engines_registered ||= begin
        @sprockets_environment.register_engine '.rb', ::Parcels::Fortitude::WidgetEngine
        @sprockets_environment.register_engine '.pcss', ::Parcels::Fortitude::AlongsideEngine
        true
      end
    end
  end
end
