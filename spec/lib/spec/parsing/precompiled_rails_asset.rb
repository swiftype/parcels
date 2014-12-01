module Spec
  module Parsing
    class PrecompiledRailsAsset
      def initialize(rails_server, asset_path)
        @rails_server = rails_server
        @asset_path = asset_path
      end

      def where_from
        "Rails precompiled asset '#{asset_path}'"
      end

      def exists?
        !! source
      end

      def source
        @source ||= begin
          assets_dir = File.join(rails_server.rails_root, 'public', 'assets')
          filename = extension = nil

          if File.basename(asset_path) =~ /^(\S+)\.([^\.]+)$/i
            filename = $1
            extension = $2
          else
            raise "Can't get filename and extension from: #{asset_path.inspect}"
          end

          entries = Dir.entries(assets_dir).select { |e| e =~ /^#{Regexp.escape(filename)}\-[0-9a-f]+\.#{Regexp.escape(extension)}$/i }

          if entries.length == 0
            :none
          elsif entries.length == 1
            path = File.join(assets_dir, entries.first)
            File.read(path)
          elsif entries.length > 1
            raise "Found multiple entries in #{assets_dir.inspect} matching #{filename.inspect}/#{extension.inspect}: #{entries.inspect}"
          end
        end

        @source unless @source == :none
      end

      def to_s
        "<PrecompiledRailsAsset '#{asset_path}'>"
      end

      private
      attr_reader :rails_server, :asset_path
    end
  end
end
