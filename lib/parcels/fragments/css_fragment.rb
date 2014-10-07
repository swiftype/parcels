module Parcels
  module Fragments
    class CssFragment
      class << self
        def to_css(parcels_environment, context, fragments)
          fragments = Array(fragments)
          fragments.map { |f| f.to_css(parcels_environment, context) }.join("\n")
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

      def to_css(parcels_environment, context)
        scss = css_string

        if wrapped? && (wrapper_css_class = source.try(:_parcels_widget_outer_element_class))
          scss = %{.#{wrapper_css_class} {
    #{scss}
  }}
        end

        fake_pathname = file
        fake_pathname = $1 if fake_pathname =~ %r{^(.*)/([^\.]+)[^/]+$}i
        fake_pathname += ".css.scss"

        if options[:engines]
          fake_pathname += options[:engines]
        end

        asset_attributes = ::Sprockets::AssetAttributes.new(parcels_environment.sprockets_environment, fake_pathname)
        processors = asset_attributes.processors
        out = process_with_processors(processors, context, scss)

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

      def process_with_processors(processors, context, data)
        result = data

        processors.each do |processor|
          template = processor.new(file) { result }
          result = template.render(context, {})
        end

        result
      end

      def engine_specs
        @engine_specs ||= begin
          out = options[:engines]
          out = Array(out).flatten.compact
          out = out.map { |engine_spec| engine_spec.split(".") }.select { |e| ! e.blank? }.compact.map { |s| s.to_s.strip.downcase }
          out = [ "scss" ] + out unless out[0] == "scss"
          out
        end
      end

      def engines
        engine_specs.map do |s|
          ::Sprockets.engines(".#{s}") || raise(ArgumentError, "No such engine #{s.inspect}; we have: #{::Sprockets.engines.keys.inspect}")
        end
      end
    end
  end
end
