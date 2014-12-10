require 'active_support/core_ext/module/delegation'

require 'parcels/utils/path_utils'

module Parcels
  class FortitudeInlineParcel
    def initialize(widget_tree, full_path)
      @widget_tree = widget_tree
      @full_path = full_path
    end

    def to_s
      "<#{self.class.name.demodulize} for #{widget_class}>"
    end

    def included_in_any_set?(set_names)
      if set_names.length == 0
        true
      else
        (widget_class._parcels_get_sets & set_names).length > 0
      end
    end

    def add_to_sprockets_context!(sprockets_context)
      if has_content?(sprockets_context)
        sprockets_context.require_asset(logical_path)
      else
        sprockets_context.depend_on_asset(logical_path)
      end
    end

    def tag
      widget_class
    end

    def tags_that_must_come_before
      widget_class.all_fortitude_superclasses
    end

    def to_css(sprockets_context)
      if widget_class.respond_to?(:_parcels_widget_class_css) &&
        (!(css = widget_class._parcels_widget_class_css(widget_tree.parcels_environment, sprockets_context)).blank?)
        css
      end
    end

    private
    attr_reader :widget_tree, :full_path

    def has_content?(sprockets_context)
      !! to_css(sprockets_context)
    end

    def logical_path
      @logical_path ||= widget_tree.logical_path_for_full_path(full_path)
    end

    def widget_class
      @widget_class ||= ::Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => [ widget_tree.root ])
    end
  end
end
