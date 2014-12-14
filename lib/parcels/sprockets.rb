require 'active_support'
require 'active_support/core_ext/string'

require "parcels/index"

::Sprockets::Environment.class_eval do
  def parcels
    @parcels ||= ::Parcels::Environment.new(self)
  end

  def index_with_parcels
    parcels.create_and_add_all_workaround_directories!
    index_without_parcels
  end

  alias_method_chain :index, :parcels
end

::Sprockets::Index.class_eval do
  # Older versions of Sprockets don't actually hang on to the environment here.
  def initialize_with_parcels(environment)
    initialize_without_parcels(environment)
    @environment ||= environment
  end

  alias_method_chain :initialize, :parcels

  def parcels
    @parcels ||= ::Parcels::Index.new(@environment.parcels)
  end
end

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*set_names)
    set_names = set_names.map do |set_name|
      set_name = set_name.to_s.strip
      set_name = $1 if set_name =~ /,?(.*?),?$/i
      set_name.strip.to_sym
    end
    context.environment.parcels.add_all_widgets_to!(context, set_names.map(&:to_sym))
  end
end

::Sprockets::AssetAttributes.class_eval do
  def format_extension_with_parcels
    out = format_extension_without_parcels
    out = nil if out && out =~ /^\.html$/i
    out
  end

  alias_method_chain :format_extension, :parcels
end

static_compiler_class = '::Sprockets::StaticCompiler'.constantize rescue nil
if static_compiler_class
  instance_methods = static_compiler_class.instance_methods(true).map(&:to_s)
  if instance_methods.include?('compile_path?')
    static_compiler_class.class_eval do
      def compile_path_with_parcels?(logical_path)
        return false if ::Parcels.is_fortitude_logical_path?(logical_path)
        compile_path_without_parcels?(logical_path)
      end

      alias_method_chain :compile_path?, :parcels
    end
  elsif instance_methods.include?('compile')
    module ::Parcels::Sprockets
      class StaticCompilerEnvProxy
        def initialize(env)
          @env = env
        end

        def each_logical_path(*args, &block)
          @env.each_logical_path do |logical_path|
            unless ::Parcels.is_fortitude_logical_path?(logical_path)
              block.call(logical_path)
            end
          end
        end

        def method_missing(name, *args, &block)
          @env.send(name, *args, &block)
        end
      end
    end

    static_compiler_class.class_eval do
      def env
        @_parcels_env_proxy ||= ::Parcels::Sprockets::StaticCompilerEnvProxy.new(@env)
      end
    end
  end
end

begin
  require 'sass/rails/importer'
rescue LoadError => le
  # oh, well
end

[ '::Sprockets::SassImporter', '::Sass::Rails::Importer' ].each do |class_name|
  klass = class_name.constantize rescue nil

  if klass
    klass.class_eval do
      if defined?(klass::GLOB)
        def find_relative_with_parcels(name, base, options)
          parcels = context.environment.parcels
          expanded_locations_to_search = context.environment.paths + [ File.dirname(base) ]

          if name =~ self.class.const_get(:GLOB) && parcels.is_underneath_root?(base)
            paths_to_search = expanded_locations_to_search

            imports = nil
            paths_to_search.each do |path_to_search|
              glob_against = Pathname.new(File.join(path_to_search.to_s, 'dummy'))
              imports = glob_imports(name, glob_against, :load_paths => [ path_to_search ])
              return imports if imports
            end
          end

          return find_relative_without_parcels(name, base, options.merge(:load_paths => expanded_locations_to_search))
        end

        alias_method_chain :find_relative, :parcels
      end
    end
  end
end
