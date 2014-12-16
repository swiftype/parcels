describe "Parcels workaround directories", :type => :system do
  context "with a simple widget" do
    before :each do
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
    end

    def all_workaround_directories_in(base_dir)
      out = [ ]
      Find.find(base_dir) do |file|
        out << file if File.basename(file) =~ /^#{Regexp.escape(::Parcels::Environment::PARCELS_WORKAROUND_DIRECTORY_NAME)}/
      end
      out
    end

    def ensure_asset_compiles!
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end
      end)
    end

    def default_widget_trees_to_add_to_sprockets
      [ ]
    end

    it "should, by default, put workaround directories inside the widget-tree root" do
      sprockets_env.parcels.add_widget_tree!(File.join(this_example_root, 'views'))
      ensure_asset_compiles!
      expect(all_workaround_directories_in(this_example_root)).to eq([
        File.join(this_example_root, "views/#{::Parcels::Environment::PARCELS_WORKAROUND_DIRECTORY_NAME}")
      ])
    end

    it "should put workaround directories elsewhere if you tell it to" do
      require 'tmpdir'
      test_dir = Dir.mktmpdir do |tempdir|
        sprockets_env.parcels.workaround_directories_root = File.join(tempdir, 'foo', 'bar')
        sprockets_env.parcels.add_widget_tree!(File.join(this_example_root, 'views'))
        ensure_asset_compiles!

        expect(all_workaround_directories_in(this_example_root)).to eq([ ])
        expect(all_workaround_directories_in(tempdir).length).to eq(1)
        expect(all_workaround_directories_in(tempdir)[0]).to match(
          /^#{Regexp.escape(File.join(tempdir, 'foo', 'bar', ::Parcels::Environment::PARCELS_WORKAROUND_DIRECTORY_NAME))}_[0-9a-f]{32}$/
        )
      end
    end

    it "should let you re-set the workaround directory location to the same thing as much as you want" do
      require 'tmpdir'
      test_dir = Dir.mktmpdir do |tempdir|
        sprockets_env.parcels.workaround_directories_root = File.join(tempdir, 'foo', 'bar')
        sprockets_env.parcels.add_widget_tree!(File.join(this_example_root, 'views'))
        ensure_asset_compiles!

        sprockets_env.parcels.workaround_directories_root = File.join(tempdir, 'foo', 'bar')
        ensure_asset_compiles!
      end
    end

    it "should give you an exception if you try to change the workaround directory location after it's been used" do
      sprockets_env.parcels.add_widget_tree!(File.join(this_example_root, 'views'))
      ensure_asset_compiles!

      expect do
        sprockets_env.parcels.workaround_directories_root = this_example_root
      end.to raise_exception(/can't set/)
    end
  end
end
