require 'parcels/set_definition'

module Parcels
  class Base
    LOGICAL_PATH_PREFIX = "_parcels".freeze
    PARCELS_DEFAULT_SET_NAME = 'all'.freeze

    attr_reader :root, :widget_roots

    def initialize(sprockets_environment)
      @sprockets_environment = sprockets_environment
      @workaround_directories_created = { }

      @set_definitions = { }

      self.root = sprockets_environment.root
      self.widget_roots = [ self.root ]
    end

    def root=(new_root)
      @root = File.expand_path(new_root)
    end

    def widget_roots=(new_widget_roots)
      new_widget_roots = Array(new_widget_roots)
      new_widget_roots = new_widget_roots.compact.map { |d| File.expand_path(d, self.root) }.uniq
      @widget_roots = new_widget_roots.freeze
    end

    def define_set!(set_definition_name, *args, &block)
      set_definition_name = set_definition_name.to_sym
      set_definitions[set_definition_name] = ::Parcels::SetDefinition.new(self, set_definition_name, *args, &block)
    end

    def set_definition(set_definition_name)
      set_definition_name = set_definition_name.to_sym
      out = set_definitions[set_definition_name]
      unless out
        if set_definition_name == PARCELS_DEFAULT_SET_NAME
          raise %{Parcels has no set defined named #{set_definition_name.inspect}.
It does have definitions for: #{set_definitions.keys.inspect}.
This probably means you didn't pass the name of a set to your 'require_parcels' directive,
and you haven't defined a set named '#{PARCELS_DEFAULT_SET_NAME}'.
Either define a set with that name (using define_set!), or pass the name of a set
that is defined to your 'require_parcels' directive.}
        else
          raise %{Parcels has no set defined named #{set_definition_name.inspect}.
It does have definitions for: #{set_definitions.keys.inspect}.
Please specify one of these names in your 'require_parcels' directive in your asset.}
        end
      end
      out
    end

    def logical_path_for(fragment_path)
      fragment_path = File.expand_path(fragment_path, root)
      view_path = view_paths.detect { |vp| fragment_path.start_with?(vp) }
      unless view_path
        raise "Fragment #{fragment_path.inspect} isn't under any of our view paths, which are: #{view_paths.inspect}"
      end

      subpath = fragment_path[(view_path.length + 1)..-1]
      File.join(LOGICAL_PATH_PREFIX, subpath)
    end

    def create_and_add_all_workaround_directories!
      all_set_definition_names.each do |set_definition_name|
        set_definition(set_definition_name).add_workaround_directory_to_sprockets!(sprockets_environment)
      end
    end

    private
    PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME = ".parcels-sprockets-workaround"

    attr_reader :sprockets_environment, :set_definitions

    def all_set_definition_names
      set_definitions.keys
    end

    def create_and_add_workaround_directory_if_needed!(view_path)
      @workaround_directories_created[view_path] ||= begin
        view_path = File.expand_path(view_path, root)
        unless view_paths.include?(view_path)
          raise "The specified view path, #{view_path.inspect}, is not any of our view paths: #{view_paths.inspect}"
        end

        workaround_directory = File.join(view_path, PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME)

        unless sprockets_environment.paths.include?(workaround_directory)
          sprockets_environment.prepend_path(workaround_directory)
        end

        FileUtils.mkdir_p(workaround_directory)
        Dir.chdir(workaround_directory) do
          unless File.symlink?(::Parcels::Base::LOGICAL_PATH_PREFIX)
            FileUtils.ln_s("..", ::Parcels::Base::LOGICAL_PATH_PREFIX)
          end
        end

        workaround_directory
      end
    end
  end
end
