# Superclasses BEFORE subclasses -- it's the last-encountered CSS rule that applies
describe "Parcels dependency sorting", :type => :system do
  it "should sort superclasses before subclasses in the generated file" do
    sequence = (0..20).map { |i| rand(500) }.uniq
    $stderr.puts "SEQUENCE: #{sequence}"

    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      creation_sequence = (0..(sequence.length - 1)).to_a.shuffle

      creation_sequence.each do |cs|
        seq = sequence[cs]
        superclass_num = sequence[cs - 1] if cs > 0
        superclass = superclass_num ? "Views::Widget#{superclass_num}" : ::FileStructureHelpers::SpecWidget

        widget "views/widget_#{seq}", :superclass => superclass do
          css %{
            p { color: #0000#{'%02d' % seq}; }
          }
        end

        file   "views/widget_#{seq}.css", %{
          div { color: #FFFF#{'%02d' % seq}; }
        }
      end
    }

    sequence.each { |s| require File.join(this_example_root, "views/widget_#{s}") }

    expected_content = { }

    sequence.each do |seq|
      expected_content["views/widget_#{seq}.css"] = {
        widget_scoped(:div) => "color: #FFFF#{'%02d' % seq}"
      }
      expected_content["views/widget_#{seq}.rb"] = {
        widget_scoped(:p) => "color: #0000#{'%02d' % seq}"
      }
    end

    expect_css_content_in('basic', expected_content)


    actual_order = [ ]

    order = css_content_order_in('basic')
    order.each_with_index do |order_data, index|
      filename = order_data[:filename]

      if filename =~ %r{^views/widget_(\d+)\.rb$}i
        num = Integer($1)
        actual_order << [ num, :rb ]
      elsif filename =~ %r{^views/widget_(\d+)\.css$}i
        num = Integer($1)
        actual_order << [ num, :css ]
      else
        raise "Got unexpected ordering data: filename is #{filename.inspect}"
      end
    end

    expected_order = [ ]
    sequence.each { |s| expected_order += [ [ s, :rb ], [ s, :css ] ] }

    expect(actual_order).to eq(expected_order)
  end
end
