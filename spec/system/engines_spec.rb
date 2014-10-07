describe "Parcels engines support", :type => :system do
  it "should not, by default, process ERb in inline CSS" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { background-image: url("foo-<%= 3 * 7 %>"); }
        }
      end
    }

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "background-image: url(\"foo-<%= 3 * 7 %>\")"
      })
  end

  it "should process ERb in inline CSS if asked to" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { background-image: url("foo-<%= 3 * 7 %>"); }
        }, :options => { :engines => '.erb' }
      end
    }

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "background-image: url(\"foo-21\")"
      })
  end
end
