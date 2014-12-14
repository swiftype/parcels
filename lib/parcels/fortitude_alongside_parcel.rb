require 'parcels/fortitude_parcel'

require 'parcels/utils/path_utils'

module Parcels
  class FortitudeAlongsideParcel < FortitudeParcel
    def self.logical_path_prefix
      "#{logical_path_prefix_base}alongside"
    end

    def to_css(sprockets_context)
      if widget_class.respond_to?(:_parcels_widget_class_alongside_css) &&
        (!(css = widget_class._parcels_widget_class_alongside_css(widget_tree.parcels_environment, sprockets_context)).blank?)
        css
      end
    end

    def tag_types_that_must_come_before
      [ ]
    end

    def tag_type
      :alongside
    end

    def usable?
      widget_class_full_path
    end

    private
    attr_reader :widget_tree, :full_path

    def widget_class_full_path
      @widget_class_full_path ||= (::Parcels::Utils::PathUtils.widget_class_file_for_alongside_file(full_path) || :none)
      @widget_class_full_path unless @widget_class_full_path == :none
    end
  end
end
