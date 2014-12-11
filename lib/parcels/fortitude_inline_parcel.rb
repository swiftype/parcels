require 'parcels/fortitude_parcel'

module Parcels
  class FortitudeInlineParcel < FortitudeParcel
    def to_css(sprockets_context)
      if widget_class.respond_to?(:_parcels_widget_class_inline_css) &&
        (!(css = widget_class._parcels_widget_class_inline_css(widget_tree.parcels_environment, sprockets_context)).blank?)
        css
      end
    end

    private
    attr_reader :widget_tree, :full_path

    def widget_class_full_path
      full_path
    end
  end
end
