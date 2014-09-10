require 'fileutils'

require 'sprockets'
require 'parcels'

describe "Parcels basic operations", :type => :system do
  before :each do |example|
    ::Parcels.view_paths = [ File.join(this_example_root, 'views') ]
  end

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

    sprockets_env.parcels.view_paths = [ File.join(this_example_root, 'views') ]

    ::Parcels._ensure_view_paths_are_symlinked!
    ::Parcels.view_paths.each do |view_path|
      sprockets_env.prepend_path(::Parcels._sprockets_workaround_directory_for(view_path))
    end

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "color: red"
      })
  end
end
