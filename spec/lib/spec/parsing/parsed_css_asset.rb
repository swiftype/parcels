require 'css_parser'

module Spec
  module Parsing
    class ParsedCssAsset
      def initialize(raw_asset)
        @raw_asset = raw_asset
      end

      def style_rules
        @style_rules ||= begin
          out = { }

          if raw_asset.source
            parser = CssParser::Parser.new
            parser.load_string!(raw_asset.source)
            parser.each_selector do |selectors, declarations, specificity, media_types|
              out[selectors] = Array(declarations).map do |declaration|
                declaration = declaration.strip
                declaration = $1 if declaration =~ /\A(.*?);\Z/mi
                declaration
              end
            end
          end

          out
        end
      end

      private
      attr_reader :raw_asset
    end
  end
end
