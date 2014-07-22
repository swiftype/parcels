require "parcels/version"
require "parcels/rails"
require "parcels/fortitude"
require "parcels/sprockets"

module Parcels
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
  end
end
