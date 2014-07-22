require 'active_support'
require 'active_support/concern'

module Parcels
  module Fortitude
    module Assets
      extend ActiveSupport::Concern

      module ClassMethods
        def _parcels_widget_outer_element_classes
          @_parcels_widget_outer_element_classes ||= begin
            out = [ _parcels_widget_outer_element_class ]
            out += superclass._parcels_widget_outer_element_classes if superclass._parcels_attributes_support_included?
            out
          end
        end

        def _parcels_widget_outer_element_class
          # TODO: What are valid characters in a CSS class name?
          @_parcels_widget_outer_element_class ||= "parcels_class_#{self.name.underscore}"
        end

        def _parcels_widget_class_css
          (@_parcels_widget_class_css || [ ]).join("\n")
        end

        def css(*args)
          _parcels_ensure_attributes_support_included!

          options = args.extract_options!
          options.assert_valid_keys(:extension, :wrap)

          @_parcels_widget_class_css ||= [ ]
          @_parcels_widget_class_css += args
        end
      end
    end
  end
end
