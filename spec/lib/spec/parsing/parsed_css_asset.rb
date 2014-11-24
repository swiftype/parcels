require 'crass'

module Spec
  module Parsing
    class ParsedCssAsset
      def initialize(raw_asset)
        @raw_asset = raw_asset
      end

      private
      attr_reader :raw_asset

      def parse_tree
        @parse_tree ||= begin
          if raw_asset.source
            ::Crass.parse(raw_asset.source)
          else
            :none
          end
        end

        @parse_tree unless @parse_tree == :none
      end
    end
  end
end
