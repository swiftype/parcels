require 'crass'

module Spec
  module Parsing
    class ParsedCssAsset
      def initialize(raw_asset)
        @raw_asset = raw_asset
      end

      def style_rules
        @style_rules ||= begin
          out = { }

          parse_tree.each do |toplevel_parse_node|
            if toplevel_parse_node[:node] == :style_rule
              selector_node = toplevel_parse_node[:selector]
              selector = selector_node[:value].to_s
              rules = [ ]

              toplevel_parse_node[:children].each do |child|
                if child[:node] == :property
                  rules << "#{child[:name]}: #{child[:value]}"
                end
              end

              out[selector] = rules if rules.length > 0
            end
          end

          out
        end
      end

      private
      attr_reader :raw_asset

      def parse_tree
        @parse_tree ||= begin
          if raw_asset.source
            ::Crass.parse(raw_asset.source)
          else
            :none
          end
        end

        @parse_tree unless @parse_tree == :none
      end
    end
  end
end
