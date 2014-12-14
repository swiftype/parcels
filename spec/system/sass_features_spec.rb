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

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'color: #fff2f7'
      end
    end)
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

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'color: #feabcd'
      end
    end)
  end

  it "should let you use @import, which should use the asset search path, by default" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file 'assets/one.scss', %{
        $mycolor1: #feabcd;
      }

      file 'views/two.scss', %{
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

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'color: #feabcd'
        expect_wrapped_rule :div, 'color: #abcdef'
      end
    end)
  end

  it "should let you add to the asset search path and use that with @import" do
    sprockets_env.append_path 'foobar'

    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file 'assets/one.scss', %{
        $mycolor1: #feabcd;
      }

      file 'foobar/two.scss', %{
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

    asset = compiled_sprockets_asset('basic')
    asset.should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'color: #feabcd'
        expect_wrapped_rule :div, 'color: #abcdef'
      end
    end)
  end
end
