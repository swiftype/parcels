module Parcels
  class Index
    def initialize(base)
      @base = base
      @workaround_directories_created = { }
    end

    def root
      base.root
    end

    def view_paths
      @view_paths ||= base.view_paths.dup.freeze
    end

    def logical_path_for(fragment_path)
      base.logical_path_for(fragment_path)
    end

    def create_and_add_all_workaround_directories!
      base.create_and_add_all_workaround_directories!
    end

    private
    attr_reader :base

    def sprockets_environment
      base.sprockets_environment
    end
  end
end
