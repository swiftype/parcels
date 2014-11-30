module Spec
  module Parsing
    class CompiledAssetFragment
      attr_reader :filename, :line_number, :source

      def initialize(compiled_asset, filename, line_number)
        @compiled_asset = compiled_asset
        @filename = filename
        @line_number = line_number
        @raw_source = nil
      end

      def where_from
        "fragment at #{filename.inspect}, line #{line_number} from #{compiled_asset.where_from}"
      end

      def source
        out = @raw_source
        out = out.gsub(%r{/\*.*?\*/}mi, '') if out
        out unless (! out) || (out.strip.length == 0)
      end

      def <<(source)
        if (effective_source = source.strip) && effective_source.length > 0
          @raw_source ||= ""
          @raw_source << effective_source
        end
      end

      def to_s
        "<CompiledAssetFragment: #{filename.inspect}, line #{line_number.inspect}>"
      end

      private
      attr_reader :compiled_asset
    end
  end
end
