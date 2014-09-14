require 'active_support/core_ext/module/delegation'

module Parcels
  module Fragments
    class FortitudeWidgetFragment
      def initialize(set, full_path)
        @set = set
        @full_path = full_path
      end

      def add_to_sprockets_context!(context)
        if has_content?(context)
          context.require_asset(logical_path)
        else
          context.depend_on_asset(logical_path)
        end
      end

      def tags
        widget_class
      end

      def tags_that_must_come_after
        widget_class.all_fortitude_superclasses
      end

      def to_css
        if widget_class.respond_to?(:_parcels_widget_class_css) &&
          (!(css = widget_class._parcels_widget_class_css).blank?)
          css
        end
      end

      private
      attr_reader :set, :full_path

      delegate :widget_roots, :to => :set

      def has_content?(context)
        !! to_css
      end

      def set_root
        set.root
      end

      def logical_path
        @logical_path ||= set.logical_path_for_full_path(full_path)
      end

      def widget_class
        @widget_class ||= ::Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => widget_roots)
      end
    end
  end
end
