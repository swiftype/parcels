require 'active_support'
require 'active_support/core_ext/string'

require 'find'

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*args)
    ::Parcels.view_paths.each do |view_path|
      next unless File.directory?(view_path)

      context.depend_on(view_path)
      Find.find(view_path) do |filename|
        # TODO: Add support for sidecar .css/.js files, etc.
        next unless File.file?(filename)
        next unless File.extname(filename).strip.downcase == ".rb"

        subpath = if filename.start_with?(view_path)
          filename[(view_path.length + 1)..-1]
        else
          raise "#{filename.inspect} doesn't start with #{view_path.inspect}?!?"
        end
        logical_path = "#{::Parcels::LOGICAL_PATH_PREFIX}/#{subpath}"

        klass = ::Fortitude::Widget.widget_class_from_file(filename, :root_dirs => ::Parcels.view_paths)
        if klass && klass.respond_to?(:_parcels_widget_class_css) && (!(css = klass._parcels_widget_class_css).blank?)
          context.require_asset(logical_path)
        else
          context.depend_on_asset(logical_path)
        end
      end
    end
  end
end
