describe "Parcels CSS prefix", :type => :system do
  context "with a CSS prefix" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          parcels_css_prefix "$mycolor1: #abcdef;\n$mycolor2: #fedcba;"

          css %{
            p { color: $mycolor1; }
          }
        end

        file 'views/my_widget.css', %{
          div { color: $mycolor2; }
        }
      }
    end

    it "should apply the prefix before inline CSS" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'color: #abcdef'
        end

        allow_additional_assets!
      end)
    end

    it "should apply the prefix before alongside CSS" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.css' do
          expect_wrapped_rule :div, 'color: #fedcba'
        end

        allow_additional_assets!
      end)
    end
  end

  context "with a CSS prefix as a block, and a superclass with one, too" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/parent_widget' do
          parcels_css_prefix_block %{do |klass, superclass_prefix|
  "p::before { content: \\"parent: \#{klass.name}, \#{superclass_prefix}\\"; }"
end}
        end

        widget 'views/child_widget', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          parcels_css_prefix_block %{do |klass, superclass_prefix|
  "p::after { content: \\"child: \#{klass.name}, \#{superclass_prefix.gsub(/"/, '_')}\\"; }"
end}

          css %{
            div { color: green; }
          }
        end
      }
    end

    it "should supply the prefixes correctly" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/child_widget.rb' do
          expect_rule 'p::after', 'content: "child: Views::ChildWidget, p::before { content: _parent: Views::ParentWidget, _; }"'
          expect_wrapped_rule :div, 'color: green'
        end
      end)
    end
  end
end
