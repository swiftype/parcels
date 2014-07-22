module Parcels
  class CssFragment
    class << self
      def to_css(fragments)
        fragments = Array(fragments)
        fragments.map(&:to_css).join("\n")
      end
    end

    def initialize(css_string, source, options)
      options.assert_valid_keys(:engines, :wrap)

      @css_string = css_string
      @source = source
      @options = options
    end

    def to_css
      out = css_string

      if options.fetch(:wrap, true) && (wrapper_css_class = source.try(:_parcels_widget_outer_element_class))
        out = %{.#{wrapper_css_class} {
  #{out}
}}
      end

      engine = ::Sass::Engine.new(out, :syntax => :scss)
      out = engine.render
      out
    end

    private
    attr_reader :css_string, :source, :options
  end
end
