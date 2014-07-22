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
        next unless File.extname(filename).strip.downcase == ".rb"

        klass = ::Fortitude::Widget.widget_class_from_file(filename, :root_dirs => ::Parcels.view_paths)
        if klass && klass.respond_to?(:_parcels_widget_class_css) && (!(css = klass._parcels_widget_class_css).blank?)
          context.require_asset(filename)
        else
          context.depend_on_asset(filename)
        end
      end
    end
  end
end
