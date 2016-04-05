require 'active_support'
require 'active_support/core_ext/string'

require "parcels/index"

module Parcels
  module Sprockets
    def self.sprockets_version_components
      @sprockets_version_components ||= ::Sprockets::VERSION.split(".").map { |x| x.to_i }
    end

    def self.requires_fix_for_protected_methods_on_directive_processor?
      RUBY_VERSION =~ /^2/ && sprockets_version_components[0] <= 2 && sprockets_version_components[1] < 11
    end
  end
end

::Sprockets::Base.class_eval do
  def each_logical_path_with_parcels(*args, &block)
    if block_given?
      each_logical_path_without_parcels(*args) do |logical_path|
        unless ::Parcels.is_fortitude_logical_path?(logical_path)
          block.call(logical_path)
        end
      end
    else
      each_logical_path_without_parcels(*args).reject do |logical_path|
        ::Parcels.is_fortitude_logical_path?(logical_path)
      end
    end
  end

  alias_method_chain :each_logical_path, :parcels
end

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

if ::Parcels::Sprockets.requires_fix_for_protected_methods_on_directive_processor?
  ::Sprockets::DirectiveProcessor.class_eval do
    instance_methods(true).select { |m| m =~ /^process_.*directive$/i }.each do |method_name|
      public method_name
    end
  end
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
          @env.each_logical_path(*args) do |logical_path|
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
        ::Parcels::Sprockets::StaticCompilerEnvProxy.new(@env)
      end
    end
  end
end

[ 'sass/rails/importer', 'sprockets/sass/importer' ].each do |filename|
  begin
    require filename
  rescue LoadError => le
    # oh, well
  end
end

[ '::Sprockets::SassImporter', '::Sass::Rails::Importer', '::Sass::Rails::SassImporter', '::Sprockets::Sass::Importer' ].each do |class_name|
  klass = class_name.constantize rescue nil

  if klass
    klass.class_eval do
      if defined?(klass::GLOB)
        def _parcels_fetch_sprockets_context(options)
          sprockets_context = (options[:custom] || { })[:sprockets_context]
          sprockets_context ||= (options[:sprockets] || { })[:context]
          sprockets_context ||= context if respond_to?(:context)
          unless sprockets_context
            raise "Unable to find the Sprockets context here; it was neither in options, nor do we have it in the class. Options keys are: #{options.keys.inspect}"
          end

          sprockets_context
        end

        def _parcels_fetch_pathnames_to_search(sprockets_context, base)
          out = sprockets_context.environment.paths + [ File.dirname(base) ]
          out = out.map do |location|
            if location.kind_of?(::Pathname)
              location
            else
              ::Pathname.new(location.to_s)
            end
          end

          out
        end

        if klass.name == 'Sass::Rails::SassImporter' && (::Sass::Rails::VERSION =~ /^5/)
          def _parcels_call_glob_imports(base, glob, options)
            glob_imports(base, glob.to_s, options)
          end
        else
          def _parcels_call_glob_imports(base, glob, options)
            glob_imports(glob.to_s, base.join("dummy"), options)
          end
        end

        def find_relative_with_parcels(name, base, options)
          sprockets_context = _parcels_fetch_sprockets_context(options)
          parcels = sprockets_context.environment.parcels

          paths_to_search = _parcels_fetch_pathnames_to_search(sprockets_context, base)

          if name =~ self.class.const_get(:GLOB) && parcels.is_underneath_root?(base)
            imports = nil
            paths_to_search.each do |path_to_search|
              combined = path_to_search.join(name)
              glob = combined.basename
              base = combined.dirname

              if base.directory?
                imports = _parcels_call_glob_imports(base, glob, options.merge(:load_paths => [ path_to_search ]))
                return imports if imports
              end
            end
          end

          load_paths = (options[:load_paths] || [ ]) + paths_to_search
          return find_relative_without_parcels(name, base, options.merge(:load_paths => load_paths))
        end

        alias_method_chain :find_relative, :parcels
      end
    end
  end
end
