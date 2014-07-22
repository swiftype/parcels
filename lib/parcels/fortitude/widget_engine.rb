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
        widget_class = ::Fortitude::Widget.widget_class_from_file(context.pathname, :root_dirs => ::Parcels.view_paths)
        widget_class.try(:_parcels_widget_class_css) || ""

=begin
        css = widget_class.try(:_parcels_class_level_css)

        css = nil
        if widget_class
          css = FortitudeParcels.css_from_fortitude_widget_class(klass)
        end

        if css && css.length > 0
          raw_css = css.join("\n")

          if (wrapper_css_class = klass.try(:parcels_wrapper_css_class))
            raw_css = ".#{wrapper_css_class} {\n#{raw_css}\n}"
          end

          require 'sass'
          engine = Sass::Engine.new(raw_css, :syntax => :scss)
          engine.render
        else
          ""
        end
=end
      end
    end
  end
end
