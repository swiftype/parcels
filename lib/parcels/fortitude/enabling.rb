require 'active_support'
require 'active_support/concern'

module Parcels
  module Fortitude
    module Enabling
      extend ActiveSupport::Concern

      module ClassMethods
        def parcels_enabled?
          out = false
          out = true if superclass.respond_to?(:parcels_enabled?) && superclass.parcels_enabled?
          out = true if @_parcels_enabled
          out
        end

        def enable_parcels!
          raise "Already enabled on #{self}!" if @_parcels_enabled

          record_tag_emission true

          @_parcels_tag_methods_module = Module.new
          const_set(:ParcelsEnablingModule, @_parcels_tag_methods_module)
          self.include @_parcels_tag_methods_module

          _parcels_ensure_all_tag_methods_overridden!

          @_parcels_enabled = true
        end

        def tags_changed!(tags)
          super
          _parcels_ensure_all_tag_methods_overridden! if parcels_enabled?
        end

        def _parcels_tag_method_overridden?(tag_name)
          @_parcels_tag_methods_overridden ||= { }
          @_parcels_tag_methods_overridden[tag_name.to_sym]
        end

        def _parcels_tag_method_overridden!(tag_name)
          @_parcels_tag_methods_overridden[tag_name.to_sym] = true
        end

        def _parcels_ensure_all_tag_methods_overridden!
          tags.each do |tag_name, tag_object|
            done = _parcels_tag_method_overridden?(tag_name)
            next if done

            tag_object.all_method_names.each do |tag_method_name|
              @_parcels_tag_methods_module.send(:define_method, tag_method_name) do |content_or_attributes = nil, attributes = nil, &block|
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
