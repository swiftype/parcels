module Spec
  module Expected
    class BaseExpectedAsset
      def initialize(root_directory, expected_subpath)
        @root_directory = root_directory
        @expected_subpath = expected_subpath
      end

      def to_s
        "<#{self.class.name} at #{expected_subpath.inspect}>"
      end

      private
      attr_reader :root_directory, :expected_subpath

      def filename
        @filename ||= begin
          if expected_subpath.kind_of?(Symbol)
            expected_subpath
          else
            File.join(root_directory, expected_subpath)
          end
        end
      end

      def applies_to_asset?(asset)
        asset.filename == filename
      end

      def applicable_assets_from(remaining_assets)
        remaining_assets.select { |a| applies_to_asset?(a) }
      end
    end
  end
end
