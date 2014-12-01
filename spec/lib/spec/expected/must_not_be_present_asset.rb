require 'spec/expected/base_expected_asset'

module Spec
  module Expected
    class MustNotBePresentAsset < BaseExpectedAsset
      def should_match(remaining_assets)
        matching = applicable_assets_from(remaining_assets)

        if matching.length > 0
          raise "Assets found that must not be present:\n  #{matching.join("\n  ")}"
        end

        [ ]
      end
    end
  end
end
