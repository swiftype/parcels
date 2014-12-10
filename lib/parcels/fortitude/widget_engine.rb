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
        parcels_environment = context.environment.parcels
        widget_class = parcels_environment.widget_class_from_file(context.pathname)

        if widget_class
          widget_class._parcels_widget_class_css(parcels_environment, context)
        else
          ""
        end
      end
    end
  end
end
