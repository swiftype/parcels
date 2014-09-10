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
    @workaround_directories_created = { }
  end

  def root
    sprockets_environment.root
  end

  def view_paths=(new_view_paths)
    new_view_paths = Array(new_view_paths).map { |vp| File.expand_path(vp, root) }
    @view_paths = new_view_paths.freeze
    @view_paths.each { |vp| create_and_add_workaround_directory_if_needed!(vp) }
  end

  def add_view_paths(new_view_paths)
    self.view_paths = (self.view_paths | new_view_paths)
  end

  alias_method :add_view_path, :add_view_paths

  def logical_path_for(fragment_path)
    fragment_path = File.expand_path(fragment_path, root)
    view_path = view_paths.detect { |vp| fragment_path.start_with?(vp) }
    unless view_path
      raise "Fragment #{fragment_path.inspect} isn't under any of our view paths, which are: #{view_paths.inspect}"
    end

    subpath = fragment_path[(view_path.length + 1)..-1]
    File.join(LOGICAL_PATH_PREFIX, subpath)
  end

  private
  attr_reader :sprockets_environment

  def create_and_add_workaround_directory_if_needed!(view_path)
    @workaround_directories_created[view_path] ||= begin
      view_path = File.expand_path(view_path, root)
      unless view_paths.include?(view_path)
        raise "The specified view path, #{view_path.inspect}, is not any of our view paths: #{view_paths.inspect}"
      end

      workaround_directory = File.join(view_path, PARCELS_SPROCKETS_WORKAROUND_DIRECTORY_NAME)

      unless sprockets_environment.paths.include?(workaround_directory)
        $stderr.puts "PREPENDING: #{workaround_directory}"
        sprockets_environment.prepend_path(workaround_directory)
      end

      FileUtils.mkdir_p(workaround_directory)
      Dir.chdir(workaround_directory) do
        unless File.symlink?(LOGICAL_PATH_PREFIX)
          FileUtils.ln_s("..", LOGICAL_PATH_PREFIX)
        end
      end

      workaround_directory
    end
  end
end
