require 'parcels/fortitude_parcel'

require 'parcels/utils/path_utils'

module Parcels
  class FortitudeAlongsideParcel < FortitudeParcel
    def to_css(sprockets_context)
      if widget_class.respond_to?(:_parcels_widget_class_alongside_css) &&
        (!(css = widget_class._parcels_widget_class_alongside_css(widget_tree.parcels_environment, sprockets_context)).blank?)
        css
      end
    end

    private
    attr_reader :widget_tree, :full_path

    def widget_class_full_path
      @widget_class_full_path ||= ::Parcels::Utils::PathUtils.widget_class_for_alongside_file(full_path)
    end
  end
end
