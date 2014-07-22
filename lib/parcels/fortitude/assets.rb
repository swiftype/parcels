require 'active_support'
require 'active_support/concern'

require 'parcels/css_fragment'

require 'sass'

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
          @_parcels_widget_outer_element_class ||= begin
            fragment = self.name.underscore.gsub(/[^A-Za-z0-9_]/, '_')
            "parcels_class_#{fragment}"
          end
        end

        def _parcels_widget_class_css
          @_parcels_widget_class_css ||= ::Parcels::CssFragment.to_css(@_parcels_css_fragments)
        end

        def _parcels_widget_class_name_to_css_class_fragment
        end

        def css(*css_strings)
          options = css_strings.extract_options!
          _parcels_ensure_attributes_support_included! if options.fetch(:wrap, true)

          @_parcels_css_fragments ||= [ ]
          @_parcels_css_fragments += css_strings.map do |css_string|
            ::Parcels::CssFragment.new(css_string, self, options)
          end

          @_parcels_widget_class_css = nil
        end
      end
    end
  end
end
