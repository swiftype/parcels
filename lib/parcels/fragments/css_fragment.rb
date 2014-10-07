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

        asset_attributes = ::Sprockets::AssetAttributes.new(parcels_environment.sprockets_environment, synthetic_filename)
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

      def synthetic_filename
        @synthetic_filename ||= begin
          synthetic_name = File.basename(file)
          synthetic_name = $1 if synthetic_name =~ /^([^\.]+)\./i
          synthetic_name << ".css.scss"
          synthetic_name << engines_as_extensions

          File.join(File.dirname(file), synthetic_name)
        end
      end

      def engines_as_extensions
        @engines_as_extensions ||= begin
          engines = options[:engines] || [ ]
          out = Array(engines).flatten.map do |component|
            component = component.to_s
            component = ".#{component}" unless component =~ /^\./
            component
          end.join(".")
          ".#{out}".gsub(/\.\.+/, '.')
        end
      end

      def process_with_processors(processors, context, data)
        result = data

        processors.each do |processor|
          template = processor.new(file) { result }
          result = template.render(context, {})
        end

        result
      end
    end
  end
end
