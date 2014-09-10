require "sprockets"
require "parcels/version"
require "parcels/rails"
require "parcels/fortitude"
require "parcels/sprockets"

class Parcels
  LOGICAL_PATH_PREFIX = "_parcels"
  PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME = ".parcels-sprockets-workaround"

  attr_reader :view_paths

  def initialize(sprockets_environment)
    @sprockets_environment = sprockets_environment
    @view_paths = [ ].freeze
  end

  def root
    sprockets_environment.root
  end

  def view_paths=(new_view_paths)
    new_view_paths = Array(new_view_paths).map { |vp| File.expand_path(vp, root) }
    @view_paths = new_view_paths.freeze
  end

  def add_view_paths(new_view_paths)
    self.view_paths = (self.view_paths | new_view_paths)
  end

  def logical_path_for(fragment_path)
    fragment_path = File.expand_path(fragment_path, root)
    view_path = view_paths.detect { |vp| fragment_path.start_with?(vp) }
    unless view_path
      raise "Fragment #{fragment_path.inspect} isn't under any of our view paths, which are: #{view_paths.inspect}"
    end

    sprockets_workaround_directory_for(view_path)

    subpath = fragment_path[(view_path.length + 1)..-1]
    File.join(LOGICAL_PATH_PREFIX, subpath)
  end

  def sprockets_workaround_directory_for(view_path)
    view_path = File.expand_path(view_path, root)
    unless view_paths.include?(view_path)
      raise "The specified view path, #{view_path.inspect}, is not any of our view paths: #{view_paths.inspect}"
    end

    out = File.join(view_path, PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME)

    unless sprockets_environment.paths.include?(out)
      sprockets_environment.prepend_view_path(out)
    end

    FileUtils.mkdir_p(out)
    Dir.chdir(out) do
      unless File.symlink?(LOGICAL_PATH_PREFIX)
        FileUtils.ln_s("..", LOGICAL_PATH_PREFIX)
      end
    end

    out
  end

  alias_method :add_view_path, :add_view_paths

  private
  attr_reader :sprockets_environment

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


    def _sprockets_workaround_directory_for(view_path)
      File.join(view_path, PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME)
    end

    def _ensure_view_paths_are_symlinked!
      return
      view_paths.each do |view_path|
        parcels_subdir = _sprockets_workaround_directory_for(view_path)
        FileUtils.mkdir_p(parcels_subdir)
        Dir.chdir(parcels_subdir) do
          unless File.symlink?(LOGICAL_PATH_PREFIX)
            FileUtils.ln_s("..", LOGICAL_PATH_PREFIX)
          end
        end
      end
    end
  end
end
