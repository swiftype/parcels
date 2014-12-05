require 'active_support/core_ext/module/delegation'

require 'parcels/set'

module Parcels
  class Index
    def initialize(environment)
      @environment = environment
      @sets = { }
    end

    delegate :root, :root=, :logical_path_for, :widget_roots, :widget_roots=, :define_set!, :is_underneath_root?, :to => :environment

    def set(name)
      sets[name] ||= ::Parcels::Set.new(environment.set_definition(name))
    end

    private
    attr_reader :environment, :sets

    delegate :sprockets_environment, :to => :environment
  end
end
