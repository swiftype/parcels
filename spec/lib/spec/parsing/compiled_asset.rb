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

      def source
        raw_asset.source
      end

      def to_s
        "<CompiledAsset for #{raw_asset}>"
      end

      def should_match(expected_asset_set, options = { })
        remaining_fragments = (fragments || [ ]).dup
        remaining_fragments = remaining_fragments.select { |f| (f.source || "").strip.length > 0 }

        found_indices = [ ]
        expected_asset_set.expected_assets.each do |expected_asset|
          matching_remaining_fragments = remaining_fragments.select { |f| expected_asset.applies_to_asset?(f) }

          if matching_remaining_fragments.length == 0
            raise "Expected match not found:\n  #{expected_asset}\nnot found in\n  #{self}"
          elsif matching_remaining_fragments.length == 1
            matching_remaining_fragment = matching_remaining_fragments.first

            unless expected_asset.asset_matches?(matching_remaining_fragment)
              raise "Asset mismatch for #{matching_remaining_fragment.where_from}: expected\n  #{expected_asset.source}\ndoes not match actual\n  #{matching_remaining_fragment.source}"
            end

            found_indices << fragments.index(matching_remaining_fragment)
            remaining_fragments.delete(matching_remaining_fragment)
          elsif matching_remaining_fragments.length > 1
            raise "Multiple fragments match:\n  #{expected_asset}\nin\n  #{self}:\n#{matching_remaining_fragments.join("\n")}"
          end
        end

        if options[:ordered] && (found_indices.sort != found_indices)
          raise "All fragments were found, but not in order, and order was required. We found fragments at indices:\n  #{found_indices.inspect}"
        end

        if (! expected_asset_set.allows_additional?) && (remaining_fragments.length > 0)
          raise "Unexpected fragments found in\n  #{self}:\nThese were found just fine:\n  #{expected_asset_set}\nbut we also found:\n  #{remaining_fragments.join("\n  ")}"
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
