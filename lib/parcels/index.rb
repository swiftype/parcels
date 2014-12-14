require 'active_support/core_ext/module/delegation'

module Parcels
  class Index
    def initialize(environment)
      @environment = environment
    end

    delegate :root, :logical_path_for, :is_underneath_root?, :add_all_widgets_to!, :widget_class_from_file, :add_widget_tree!, :to => :environment

    private
    attr_reader :environment

    delegate :sprockets_environment, :to => :environment
  end
end
