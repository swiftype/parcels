require 'spec/parsing/parsed_css_asset'

require 'spec/expected/base_expected_asset'

module Spec
  module Expected
    class ExpectedAsset < BaseExpectedAsset
      def initialize(root_directory, expected_subpath, &block)
        super(root_directory, expected_subpath)

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
        selector = selector.to_s
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

      def should_match(remaining_assets)
        matching_remaining_assets = applicable_assets_from(remaining_assets)

        if matching_remaining_assets.length == 0
          raise "Expected match not found:\n  #{self}\nnot found in these assets:\n    #{remaining_assets.join("\n    ")}"
        elsif matching_remaining_assets.length == 1
          matching_remaining_asset = matching_remaining_assets.first

          unless asset_matches?(matching_remaining_asset)
            raise "Asset mismatch for #{matching_remaining_asset.where_from}: expected\n  #{source}\ndoes not match actual\n  #{matching_remaining_asset.source}"
          end

          [ matching_remaining_asset ]
        elsif matching_remaining_assets.length > 1
          raise "Multiple assets match:\n  #{self}\nin:\n#{matching_remaining_assets.join("\n")}"
        end
      end

      def parcels_wrapping_class
        @parcels_wrapping_class ||= begin
          out = expected_subpath.dup
          out = $1 if out =~ /^(.*?)\.([^\/]+)$/i
          out = out.gsub('/', '__').gsub(/[^A-Za-z0-9_]/, '_')
          "parcels_class__#{out}"
        end
      end

      private
      attr_reader :expected_rules

      def extra_rules_allowed?
        !! @allow_extra_rules
      end

      def wrap_selector(selector)
        if selector
          ".#{parcels_wrapping_class} #{selector}"
        else
          ".#{parcels_wrapping_class}"
        end
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
    end
  end
end
