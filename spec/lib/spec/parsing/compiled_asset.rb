require 'spec/parsing/compiled_asset_fragment'

module Spec
  module Parsing
    class CompiledAsset
      def initialize(raw_asset)
        @raw_asset = raw_asset
      end

      def where_from
        "compiled asset for #{raw_asset.where_from}"
      end

      def fragments
        @fragments ||= begin
          if (raw_source = raw_asset.source)
            parse_fragments_from_raw_source(raw_source)
          else
            :none
          end
        end

        @fragments unless @fragments == :none
      end

      def assert_matches!(expected_asset)
        raise "No fragments!" unless fragments
        fragments_matching = fragments.select { |f| expected_asset.applies_to_asset?(f) }

        if fragments_matching.length == 0
          raise "Expected match not found:\n  #{expected_asset}\nnot found in\n  #{self}"
        elsif fragments_matching.length == 1
          fragment = fragments_matching.first
          unless expected_asset.asset_matches?(fragment)
            raise "Asset mismatch for #{fragment.where_from}:\n  #{expected_asset.source}\ndoes not match\n  #{fragment.source}"
          end
        elsif fragments_matching.length > 1
          raise "Multiple fragments match:\n  #{expected_asset}\nin\n  #{self}"
        end
      end

      private
      attr_reader :raw_asset

      FROM_LINE_REGEXP = %r{^\s*\/\*\s*From[\s'"]*([^'"]+?)\s*[\s'"]*:\s*(\d+)\s*\*/\s*$}i
      BREAK_LINE_REGEXP = %r{^\s*//\s*===\s*BREAK\s*===\s*$}i

      def parse_fragments_from_raw_source(raw_source)
        remaining = raw_source.strip
        out = [ ]

        current_fragment = ::Spec::Parsing::CompiledAssetFragment.new(self, :head, nil)
        out << current_fragment

        while remaining && remaining.length > 0
          if (from_line_match = FROM_LINE_REGEXP.match(remaining))
            current_fragment << remaining[0..(from_line_match.begin(0) - 1)] if from_line_match.begin(0) > 0
            current_fragment = ::Spec::Parsing::CompiledAssetFragment.new(
              self, from_line_match.captures[0], Integer(from_line_match.captures[1]))
            out << current_fragment
            remaining = remaining[(from_line_match.end(0) + 1)..-1]
          else
            if (break_line_match = BREAK_LINE_REGEXP.match(remaining))
              current_fragment << remaining[0..(break_line_match.begin(0) - 1)]
              tail_fragment = ::Spec::Parsing::CompiledAssetFragment.new(self, :tail, nil)
              tail_fragment << remaining[(break_line_match.end(0) + 1)..-1]
              out << tail_fragment
            else
              current_fragment << remaining
            end

            remaining = nil
          end
        end

        out
      end
    end
  end
end
