require 'tilt'

module Parcels
  module Fortitude
    class WidgetEngine < Tilt::Template
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
        parcels = context.environment.parcels
        widget_class = ::Fortitude::Widget.widget_class_from_file(context.pathname, :root_dirs => parcels.widget_roots)
        widget_class.try(:_parcels_widget_class_css) || ""
      end
    end
  end
end
