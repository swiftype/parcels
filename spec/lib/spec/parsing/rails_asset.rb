module Spec
  module Parsing
    class RailsAsset
      def initialize(rails_server, asset_path)
        @rails_server = rails_server
        @asset_path = asset_path
      end

      def where_from
        "Rails asset '#{asset_path}'"
      end

      def exists?
        !! source
      end

      def source
        @source ||= (rails_server.get("assets/#{asset_path}", :nil_on_not_found => true) || :none)
        @source unless @source == :none
      end

      def to_s
        "<RailsAsset '#{asset_path}'>"
      end

      private
      attr_reader :rails_server, :asset_path
    end
  end
end
