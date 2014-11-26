module Spec
  module Parsing
    class SprocketsAsset
      def initialize(sprockets_env, asset_path)
        @sprockets_env = sprockets_env
        @asset_path = asset_path
      end

      def where_from
        "raw Sprockets asset '#{asset_path}'"
      end

      def exists?
        !! asset
      end

      def source
        asset.source if asset
      end

      private
      attr_reader :sprockets_env, :asset_path

      def asset
        @asset ||= (sprockets_env.find_asset(asset_path) || :none)
        @asset unless @asset == :none
      end
    end
  end
end
