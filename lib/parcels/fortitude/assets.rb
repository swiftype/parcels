require 'active_support'
require 'active_support/concern'

require 'parcels/fragments/css_fragment'

require 'sass'

module Parcels
  module Fortitude
    module Assets
      extend ActiveSupport::Concern

      module ClassMethods
        def _parcels_widget_outer_element_classes
          @_parcels_widget_outer_element_classes ||= begin
            out = [ ]
            out << _parcels_widget_outer_element_class if _parcels_wrapping_css_class_required?
            out += superclass._parcels_widget_outer_element_classes if superclass.respond_to?(:_parcels_attributes_support_included?) && superclass._parcels_attributes_support_included?
            out
          end
        end

        def _parcels_widget_outer_element_class
          @_parcels_widget_outer_element_class ||= begin
            fragment = self.name.downcase.gsub(/[^A-Za-z0-9_]/, '_')
            "parcels_class__#{fragment}"
          end
        end

        def _parcels_widget_class_css
          @_parcels_widget_class_css ||= ::Parcels::Fragments::CssFragment.to_css(@_parcels_css_fragments || [ ])
        end

        def _parcels_wrapping_css_class_required?
          @_parcels_wrapping_css_class_required
        end

        def _parcels_wrapping_css_class_required!
          @_parcels_wrapping_css_class_required = true
        end

        def _parcels_add_wrapper_css_classes_to(attributes, wrapper_classes)
          out = attributes || { }
          key = out.key?('class') ? 'class' : :class
          out[key] = Array(out[key]) + wrapper_classes
          out
        end

        def css(*css_strings)
          unless parcels_enabled?
            klass = self
            superclasses = all_fortitude_superclasses

            raise %{Before using this Parcels method, you must first enable Parcels on this class. Simply
call 'enable_parcels!', a class method, on the base widget class you want to enable -- typically, this
is your base Fortitude widget class.

This class is #{klass.name};
you may want to enable Parcels on any of its Fortitude superclasses, which are:
#{superclasses.map(&:name).join("\n")}}
          end

          options = css_strings.extract_options!
          if options.fetch(:wrap, true)
            _parcels_wrapping_css_class_required!
          end

          caller_line = caller[0]
          if caller_line =~ /^(.*)\s*:\s*(\d+)\s*:\s*in\s+/i
            caller_file = $1
            caller_line = Integer($2)
          else
            caller_file = caller_line
            caller_line = nil
          end

          @_parcels_css_fragments ||= [ ]
          @_parcels_css_fragments += css_strings.map do |css_string|
            ::Parcels::Fragments::CssFragment.new(css_string, self, caller_file, caller_line, options)
          end

          @_parcels_widget_class_css = nil
        end
      end
    end
  end
end
