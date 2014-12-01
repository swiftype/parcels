require 'spec/expected/expected_asset'
require 'spec/expected/must_not_be_present_asset'

module Spec
  module Expected
    class ExpectedAssetSet
      def initialize(root_directory, &block)
        @root_directory = root_directory
        @expected_assets = [ ]
        @allows_additional = false

        instance_eval(&block) if block
      end

      def asset(subpath, &block)
        expected_asset = Spec::Expected::ExpectedAsset.new(root_directory, subpath, &block)
        @expected_assets << expected_asset
      end

      def asset_must_not_be_present(subpath)
        expected_asset = Spec::Expected::MustNotBePresentAsset.new(root_directory, subpath)
        @expected_assets << expected_asset
      end

      def expected_assets
        @expected_assets
      end

      def allow_additional_assets!
        @allows_additional = true
      end

      def allows_additional?
        !! @allows_additional
      end

      def to_s
        "<ExpectedAssetSet: #{@expected_assets.length} assets:\n  #{@expected_assets.join("\n  ")}>"
      end

      private
      attr_reader :root_directory
    end
  end
end
