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
end
