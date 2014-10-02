module Parcels
  module Fragments
    class CssFragment
      class << self
        def to_css(parcels_environment, fragments)
          fragments = Array(fragments)
          fragments.map { |f| f.to_css(parcels_environment) }.join("\n")
        end
      end

      def initialize(css_string, source, file, line, options)
        options.assert_valid_keys(:engines, :wrap)

        @css_string = css_string
        @source = source
        @file = file
        @line = line
        @options = options
      end

      def wrapping_css_class_required?
        wrapped?
      end

      def to_css(parcels_environment)
        out = css_string

        if wrapped? && (wrapper_css_class = source.try(:_parcels_widget_outer_element_class))
          out = %{.#{wrapper_css_class} {
    #{out}
  }}
        end

        engine = ::Sass::Engine.new(out, :syntax => :scss)
        out = engine.render
        header_comment + out
      end

      private
      attr_reader :css_string, :source, :options, :file, :line

      def header_comment
        out = "/* From '#{file}'"
        out << ":#{line}" if line
        out << " */\n"
        out
      end

      def wrapped?
        options.fetch(:wrap, true)
      end
    end
  end
end
