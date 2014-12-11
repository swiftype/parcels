require 'tilt'

module Parcels
  module Fortitude
    class FortitudeEngine < Tilt::Template
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
          css_from_widget_class(widget_class, parcels_environment, context)
        else
          ""
        end
      end

      def css_from_widget_class(widget_class, parcels_environment, context)
        raise "must implement in #{self.class.name}"
      end
    end
  end
end
