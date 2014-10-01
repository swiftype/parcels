describe "Parcels SASS features support", :type => :system do
  it "should allow using features like addition" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { color: #b9f2f7 + #ff0000; }
        }
      end
    }

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "color: #fff2f7"
      })
  end

  it "should allow using variables" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          $mycolor: #feabcd;
          p { color: $mycolor; }
        }
      end
    }

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "color: #feabcd"
      })
  end

  it "should let you use @import, which should use the asset search path, by default" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file 'assets/one.css', %{
        $mycolor1: #feabcd;
      }

      file 'views/two.css', %{
        $mycolor2: #abcdef;
      }

      widget 'views/my_widget' do
        css %{
          @import "one";
          @import "two";
          p { color: $mycolor1; }
          div { color: $mycolor2; }
        }
      end
    }

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "color: #feabcd",
        widget_scoped(:div) => "color: #abcdef"
      })
  end

  it "should let you add to the asset search path and use that with @import"
end
