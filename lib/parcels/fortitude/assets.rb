require 'active_support'
require 'active_support/concern'

require 'parcels/fragments/css_fragment'

require 'sass'

module Parcels
  module Fortitude
    module Assets
      extend ActiveSupport::Concern

      module ClassMethods
        def inherited(new_class)
          super(new_class)

          if respond_to?(:caller_locations, true) && false
            locations = caller_locations(1, 1)
            filename = locations.first.absolute_path
            new_class._parcels_inherited_called_from(filename)
          else
            string = caller[0]
            if string =~ /^([^:]+):\d+/
              new_class._parcels_inherited_called_from($1)
            else
              raise "Parcels: #{new_class} inherited from #{self.name}, but caller string was unparseable: '#{string}'"
            end
          end
        end

        def _parcels_inherited_called_from(filename)
          @_parcels_class_definition_files ||= [ ]
          @_parcels_class_definition_files << filename
        end

        def _parcels_class_definition_files
          @_parcels_class_definition_files ||= [ ]
        end

        def _parcels_widget_outer_element_classes
          @_parcels_widget_outer_element_classes ||= begin
            out = [ ]
            out << _parcels_widget_outer_element_class if _parcels_wrapping_css_class_required?
            out += superclass._parcels_widget_outer_element_classes if superclass.respond_to?(:parcels_enabled?) && superclass.parcels_enabled?
            out
          end
        end

        def _parcels_css_fragments
          _parcels_alongside_css_fragments + _parcels_inline_css_fragments
        end

        def _parcels_widget_outer_element_class
          @_parcels_widget_outer_element_class ||= begin
            class_suffix = self.name.gsub('::', '__').underscore.gsub(/[^A-Za-z0-9_]/, '_')

            "parcels_class__#{class_suffix}"
          end
        end

        def _parcels_widget_class_css(parcels_environment, context)
          ::Parcels::Fragments::CssFragment.to_css(parcels_environment, context, _parcels_css_fragments)
        end

        def _parcels_wrapping_css_class_required?
          _parcels_css_fragments.detect { |f| f.wrapping_css_class_required? }
        end

        def _parcels_alongside_css_fragments
          @_parcels_alongside_css_fragments ||= _parcels_alongside_filenames.map do |filename|
            if File.exist?(filename)
              ::Parcels::Fragments::CssFragment.new(File.read(filename), self, filename, 1, { })
            end
          end.compact
        end

        def _parcels_alongside_filenames
          out = [ ]

          _parcels_class_definition_files.each do |filename|
            filename = $1 if filename =~ /^(.*)\.rb$/i
            out << "#{filename}.css"
          end

          out.select { |f| File.file?(f) }
        end

        def _parcels_add_wrapper_css_classes_to(attributes, wrapper_classes)
          out = attributes || { }
          key = out.key?('class') ? 'class' : :class
          out[key] = Array(out[key]) + wrapper_classes
          out
        end

        def _parcels_inline_css_fragments
          @_parcels_inline_css_fragments ||= [ ]
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

          caller_line = caller[0]
          if caller_line =~ /^(.*)\s*:\s*(\d+)\s*:\s*in\s+/i
            caller_file = $1
            caller_line = Integer($2)
          else
            caller_file = caller_line
            caller_line = nil
          end

          @_parcels_inline_css_fragments ||= [ ]
          @_parcels_inline_css_fragments += css_strings.map do |css_string|
            ::Parcels::Fragments::CssFragment.new(css_string, self, caller_file, caller_line, options)
          end
        end
      end
    end
  end
end
