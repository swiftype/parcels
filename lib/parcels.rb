require "parcels/version"
require "parcels/rails"
require "parcels/fortitude"
require "parcels/sprockets"

module Parcels
  LOGICAL_PATH_PREFIX = "_parcels"
  PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME = ".parcels-sprockets-workaround"

  class << self
    def view_paths
      @view_paths = (@view_paths || [ ]).map { |vp| File.expand_path(vp) }
      @view_paths
    end

    def view_paths=(new_view_paths)
      new_view_paths = Array(new_view_paths)
      new_view_paths = new_view_paths.map { |nvp| File.expand_path(nvp) }
      @view_paths = new_view_paths
    end


    def _sprockets_workaround_directories
      view_paths.map { |vp| _sprockets_workaround_directory_for(vp) }
    end

    def _sprockets_workaround_directory_for(view_path)
      File.join(view_path, PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME)
    end

    def _ensure_view_paths_are_symlinked!
      view_paths.each do |view_path|
        parcels_subdir = _sprockets_workaround_directory_for(view_path)
        $stderr.puts "ensuring #{view_path.inspect} is symlinked; making: #{parcels_subdir}"
        FileUtils.mkdir_p(parcels_subdir)
        Dir.chdir(parcels_subdir) do
          unless File.symlink?(LOGICAL_PATH_PREFIX)
            $stderr.puts "in #{Dir.pwd}, doing ln_s"
            FileUtils.ln_s("..", LOGICAL_PATH_PREFIX)
          end
        end
      end
    end
  end
end
