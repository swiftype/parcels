require 'spec/parsing/parsed_css_asset'
require 'awesome_print'

module Spec
  module Expected
    class ExpectedAsset
      def initialize(root_directory, expected_subpath, &block)
        @root_directory = root_directory
        @expected_subpath = expected_subpath

        @expected_rules = { }
        @allow_extra_rules = false

        instance_eval(&block) if block
      end

      def source
        out = ""
        expected_rules.each do |selector, rules|
          out << "#{selector} {\n"
          rules.each do |rule|
            out << "  #{rule}\n"
          end
          out << "}\n\n"
        end
        out.strip
      end

      def expect_rules(selector, *rules)
        expected_rules[selector] ||= [ ]
        expected_rules[selector] += rules
      end
      alias_method :expect_rule, :expect_rules

      def expect_wrapped_rules(selector, *rules)
        wrapped_selector = wrap_selector(selector)
        expect_rules(wrapped_selector, *rules)
      end
      alias_method :expect_wrapped_rule, :expect_wrapped_rules

      def allow_extra_rules!
        @allow_extra_rules = true
      end

      def applies_to_asset?(asset)
        asset.filename == filename
      end

      def asset_matches?(asset)
        parsed_asset = ::Spec::Parsing::ParsedCssAsset.new(asset)

        actual_rules = parsed_asset.style_rules.dup

        expected_rules.each do |expected_selector, expected_rules_for_this_selector|
          actual_rules_for_this_selector = actual_rules[expected_selector]
          return false unless actual_rules_for_this_selector
          return false unless actual_rules_for_this_selector == expected_rules_for_this_selector
        end

        true
      end

      def to_s
        "<ExpectedAsset at #{expected_subpath.inspect}>"
      end

      private
      attr_reader :root_directory, :expected_subpath, :expected_rules

      def filename
        @filename ||= File.join(root_directory, expected_subpath)
      end

      def extra_rules_allowed?
        !! @allow_extra_rules
      end

      def parcels_selector_prefix
        @parcels_selector_prefix ||= begin
          out = expected_subpath.dup
          out = $1 if out =~ /^(.*)(\.html\.rb|\.rb|\.css)$/i
          out = out.gsub('/', '__').gsub(/[^A-Za-z0-9_]/, '_')
          "parcels_class__#{out}"
        end
      end

      def wrap_selector(selector)
        ".#{parcels_selector_prefix} #{selector}"
      end
    end
  end
end
