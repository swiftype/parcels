require 'parcels/css_fragment'
require 'tilt'

module Parcels
  module Fortitude
    class AlongsideEngine < Tilt::Template
      self.default_mime_type = 'text/css'

      def self.engine_initialized?
        true
      end

      def initialize_engine
        require_template_library 'fortitude'
      end

      def prepare
      end

      def evaluate(context, locals, &block)
        widget_filename = File.basename(context.pathname.to_s)
        widget_filename = $1 if widget_filename =~ /^(.*?)\./
        widget_filename += ".rb"
        widget_filename = File.join(File.dirname(context.pathname.to_s), widget_filename)

        widget_class = ::Fortitude::Widget.widget_class_from_file(widget_filename, :root_dirs => ::Parcels.view_paths)
        fragment = ::Parcels::CssFragment.new(File.read(context.pathname.to_s), widget_class, context.pathname.to_s, 1, { })
        fragment.to_css
      end
    end
  end
end
