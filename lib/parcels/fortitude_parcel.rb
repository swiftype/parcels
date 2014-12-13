require 'active_support/core_ext/module/delegation'

require 'parcels/utils/path_utils'

module Parcels
  class FortitudeParcel
    def initialize(widget_tree, full_path)
      @widget_tree = widget_tree
      @full_path = full_path
    end

    def to_s
      "<#{self.class.name.demodulize} for #{widget_class}>"
    end

    def inspect
      "<#{self.class.name.demodulize} for #{widget_class}, tree #{widget_tree}>"
    end

    def usable?
      true
    end

    def included_in_any_set?(set_names)
      if set_names.length == 0
        true
      else
        result = (widget_class._parcels_get_sets(full_path) & set_names)
        result.length > 0
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
      [ tag_type, widget_class ]
    end

    def tags_that_must_come_before
      out = tag_types_that_must_come_before.map { |tt| [ tt, widget_class ] }
      widget_class.all_fortitude_superclasses.each do |superclass|
        all_tag_types.each do |tt|
          out << [ tt, superclass ]
        end
      end
      out
    end

    def all_tag_types
      [ :alongside, :inline ]
    end

    def tag_type
      raise "must implement in #{self.class.name}"
    end

    def tag_types_that_must_come_before
      raise "must implement in #{self.class.name}"
    end

    def to_css(sprockets_context)
      raise "must implement in #{self.class.name}"
    end

    private
    attr_reader :widget_tree, :full_path

    def has_content?(sprockets_context)
      !! to_css(sprockets_context)
    end

    def subpath
      @subpath ||= widget_tree.subpath_to(full_path)
    end

    def logical_path
      @logical_path ||= File.join(self.class.logical_path_prefix, subpath)
    end

    def widget_class_full_path
      raise "must implement in #{self.class.name}"
    end

    def widget_class
      @widget_class ||= ::Fortitude::Widget.widget_class_from_file(widget_class_full_path, :root_dirs => [ widget_tree.root ])
    end
  end
end
