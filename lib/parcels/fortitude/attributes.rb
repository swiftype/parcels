require 'active_support'
require 'active_support/concern'

module Parcels
  module Fortitude
    module Attributes
      extend ActiveSupport::Concern

      included do
        _parcels_override_all_tag_methods!
      end

      module ClassMethods
        def tags_changed!(tags)
          super
          _parcels_override_all_tag_methods!
        end

        def _parcels_attributes_support_included?
          true
        end

        def _parcels_ensure_attributes_support_included!
          # nothing to do here
        end

        def _parcels_add_wrapper_css_classes_to(attributes, wrapper_classes)
          out = attributes || { }
          key = out.key?('class') ? 'class' : :class
          out[key] = Array(out[key]) + wrapper_classes
          out
        end

        private
        def _parcels_override_all_tag_methods!
          tags.each do |tag_name, tag_object|
            tag_object.all_method_names.each do |tag_method_name|
              define_method(tag_method_name) do |content_or_attributes = nil, attributes = nil, &block|
                directly_inside = rendering_context.current_element_nesting.last
                if directly_inside.kind_of?(::Fortitude::Widget) && (css_wrapper_classes = directly_inside.class.try(:_parcels_widget_outer_element_classes))
                  if attributes || content_or_attributes.kind_of?(String)
                    super(content_or_attributes, self.class._parcels_add_wrapper_css_classes_to(attributes, css_wrapper_classes), &block)
                  else
                    super(self.class._parcels_add_wrapper_css_classes_to(content_or_attributes, css_wrapper_classes), attributes, &block)
                  end
                else
                  super(content_or_attributes, attributes, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end
