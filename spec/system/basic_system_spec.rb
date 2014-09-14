require 'fileutils'

require 'sprockets'
require 'parcels'

describe "Parcels basic operations", :type => :system do
  it "should aggregate the CSS from a simple widget properly" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { color: red; }
        }
      end
    }

    # sprockets_env.parcels.view_paths = [ File.join(this_example_root, 'views') ]
    sprockets_env.parcels.define_set!('all', File.join(this_example_root, 'views'))

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "color: red"
      })
  end
end
