# Superclasses BEFORE subclasses -- it's the last-encountered CSS rule that applies
describe "Parcels dependency sorting", :type => :system do
  it "should sort superclasses before subclasses in the generated file" do
    sequence = (0..20).map { |i| rand(500) }.uniq

    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      creation_sequence = (0..(sequence.length - 1)).to_a.shuffle

      creation_sequence.each do |cs|
        seq = sequence[cs]
        superclass_num = sequence[cs - 1] if cs > 0
        superclass = superclass_num ? "Views::Widget#{superclass_num}" : ::Spec::Fixtures::WidgetBase

        widget "views/widget#{seq}", :superclass => superclass do
          css %{
            p { color: #0000#{'%02d' % seq}; }
          }
        end

        file   "views/widget#{seq}.css", %{
          div { color: #FFFF#{'%02d' % seq}; }
        }
      end
    }

    sequence.each { |s| require File.join(this_example_root, "views/widget#{s}") }

    compiled_sprockets_asset('basic').should_match((file_assets do
      sequence.each do |seq|
        # It's important that we keep .css before .rb here -- because we want CSS in the .rb file (_i.e._, directly
        # in the widget class itself) to take priority over CSS in the .css alongside file.
        asset "views/widget#{seq}.css" do
          expect_wrapped_rule :div, "color: #FFFF#{'%02d' % seq}"
        end

        asset "views/widget#{seq}.rb" do
          expect_wrapped_rule :p, "color: #0000#{'%02d' % seq}"
        end
      end
    end), :ordered => true)
  end
end
