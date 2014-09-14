require 'active_support/core_ext/module/delegation'

require 'parcels/set'

module Parcels
  class Index
    def initialize(base)
      @base = base
      @sets = { }
    end

    delegate :root, :logical_path_for, :widget_roots, :to => :base

    def view_paths
      @view_paths ||= base.view_paths.dup.freeze
    end

    def set(name)
      sets[name] ||= ::Parcels::Set.new(base.set_definition(name))
    end

    private
    attr_reader :base, :sets

    delegate :sprockets_environment, :to => :base
  end
end
