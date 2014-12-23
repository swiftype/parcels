require 'spec/parsing/parsed_css_asset'

require 'spec/expected/base_expected_asset'

module Spec
  module Expected
    class ExpectedAsset < BaseExpectedAsset
      def initialize(root_directory, expected_subpath, options = { }, &block)
        super(root_directory, expected_subpath)

        @expected_rules = { }
        @allow_extra_rules = false
        @options = options

        options.assert_valid_keys(:sequencing)

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
          message = "Expected match not found:\n  #{self}\nnot found in these assets:"
          remaining_assets.each do |remaining_asset|
            message << "\n\n    #{remaining_asset}:\n        #{remaining_asset.source}\n"
          end
          raise message
        elsif matching_remaining_assets.length == 1 || options[:sequencing]
          matching_remaining_asset = matching_remaining_assets.first

          unless asset_matches?(matching_remaining_asset)
            raise "Asset mismatch for #{matching_remaining_asset.where_from}: expected\n  #{source}\ndoes not match actual\n  #{matching_remaining_asset.source}"
          end

          [ matching_remaining_asset ]
        elsif matching_remaining_assets.length > 1
          message = "Multiple assets match:\n  #{self}\nin:"
          matching_remaining_assets.each do |matching_remaining_asset|
            message << "\n\n    #{matching_remaining_asset}:\n        #{matching_remaining_asset.source}\n"
          end
          raise message
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
      attr_reader :expected_rules, :options

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

          matches = (actual_rules_for_this_selector.length == expected_rules_for_this_selector.length)
          if matches
            actual_rules_for_this_selector.each_with_index do |actual_rule, index|
              expected_rule = expected_rules_for_this_selector[index]

              this_matches = if expected_rule.kind_of?(String)
                actual_rule == expected_rule
              elsif expected_rule.kind_of?(Regexp)
                actual_rule =~ expected_rule
              else
                false
              end

              matches &&= this_matches
            end

            actual_rules.delete(expected_selector)
          end

          return false unless matches
        end

        if actual_rules.length > 0 && (! extra_rules_allowed?)
          return false
        end

        true
      end
    end
  end
end
