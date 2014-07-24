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
            out = [ ]
            out << _parcels_widget_outer_element_class if _parcels_wrapping_css_class_required?
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

        def _parcels_widget_class_css(this_widget_filename)
          @_parcels_widget_class_css ||= begin
            fragments = _parcels_alongside_fragments(this_widget_filename)
            fragments += (@_parcels_css_fragments || [ ])
            ::Parcels::CssFragment.to_css(fragments.compact)
          end
        end

        def _parcels_wrapping_css_class_required?
          @_parcels_wrapping_css_class_required
        end

        def _parcels_wrapping_css_class_required!
          @_parcels_wrapping_css_class_required = true
        end

        def _parcels_alongside_fragments(this_widget_filename)
          directory = File.dirname(this_widget_filename)
          alongside_files = [ ]

          simple_filename = File.basename(this_widget_filename)
          simple_filename = $1 if simple_filename =~ /^(.*)\.rb$/i
          escaped_filename = Regexp.escape(simple_filename)

          Dir.entries(directory).each do |entry|
            full_path = File.join(directory, entry)
            alongside_files << full_path if File.file?(full_path) && entry =~ /^#{escaped_filename}\.(css|.*\.css)/i
          end

          alongside_files.map do |alongside_file|
            ::Parcels::CssFragment.new(File.read(alongside_file), self, alongside_file, 1, { })
          end
        end

        def css(*css_strings)
          options = css_strings.extract_options!
          if options.fetch(:wrap, true)
            _parcels_ensure_attributes_support_included!
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
            ::Parcels::CssFragment.new(css_string, self, caller_file, caller_line, options)
          end

          @_parcels_widget_class_css = nil
        end
      end
    end
  end
end
