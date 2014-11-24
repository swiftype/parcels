module Spec
  module Parsing
    class CompiledAssetFragment
      attr_reader :filename, :line_number

      def initialize(compiled_asset, filename, line_number)
        @compiled_asset = compiled_asset
        @filename = filename
        @line_number = line_number
        @content = nil
      end

      def <<(content)
        if (effective_content = content.strip) && effective_content.length > 0
          @content ||= ""
          @content << effective_content
        end
      end

      private
      attr_reader :compiled_asset, :content
    end
  end
end
