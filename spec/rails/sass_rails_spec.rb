describe "Parcels Rails SASS support", :type => :rails do
  uses_rails_with_template :sass_rails_spec

  it "should use Rails' asset search path for Sass @import in inline CSS and alongside CSS" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/default_sass_import.rb' do
        expect_wrapped_rule :p, 'color: #afedcb'
        expect_wrapped_rule :div, 'color: #0b1c2d'
        expect_wrapped_rule :span, 'color: #9a8b7c'
      end

      asset 'views/sass_rails_spec/default_sass_import.pcss' do
        expect_wrapped_rule :h1, 'color: #11abcd'
        expect_wrapped_rule :h2, 'color: #12abcd'
        expect_wrapped_rule :h3, 'color: #13abcd'
      end

      allow_additional_assets!
    end)
  end

  it "should let you change Rails' asset search path, and use that for Sass @import" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/added_asset_path.rb' do
        expect_wrapped_rule :p, 'color: #a0b1c2'
      end

      asset 'views/sass_rails_spec/added_asset_path.pcss' do
        expect_wrapped_rule :div, 'color: #a0b1c2'
      end

      allow_additional_assets!
    end)
  end

  it "should support other features of sass-rails" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/other_features.rb' do
        expect_wrapped_rule :p, 'color: #050709'
      end

      asset 'views/sass_rails_spec/other_features.pcss' do
        expect_wrapped_rule :div, 'color: #040608'
      end

      allow_additional_assets!
    end)
  end

  it "should allow you to import entire directories of files, relative to app/assets/, using 'import \"foo/*\"" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/import_directory.rb' do
        expect_wrapped_rule :p, 'color: #a1a1a1'
        expect_wrapped_rule :div, 'color: #a2a2a2'
      end

      asset 'views/sass_rails_spec/import_directory.pcss' do
        expect_wrapped_rule :span, 'color: #b1b1b1'
        expect_wrapped_rule :section, 'color: #b2b2b2'
      end

      allow_additional_assets!
    end)
  end

  it "should also allow you to import entire directories of files, relative to the view itself, using 'import \"foo/*\"" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/import_view_relative_directory.rb' do
        expect_wrapped_rule :p, 'color: #1a1a1a'
        expect_wrapped_rule :div, 'color: #2a2a2a'
      end

      asset 'views/sass_rails_spec/import_view_relative_directory.pcss' do
        expect_wrapped_rule :span, 'color: #1b1b1b'
        expect_wrapped_rule :section, 'color: #2b2b2b'
      end

      allow_additional_assets!
    end)
  end

  it "should support 'asset-path', 'asset-url', 'image-url', 'asset-data-url', etc." do
    asset = compiled_rails_asset('application.css')

    asset_prefix = if rails_server.rails_version =~ /^3/ then "/assets" else "" end
    image_prefix = if rails_server.rails_version =~ /^3/ then "/assets" else "/images" end

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/asset_url.rb' do
        expect_wrapped_rule :p, "background: url(\"#{asset_prefix}/foo/bar.jpg\")"
        expect_wrapped_rule :div, "background: url(#{asset_prefix}/bar/baz.png)"
      end

      asset 'views/sass_rails_spec/asset_url.pcss' do
        expect_wrapped_rule :span, "background: url(#{image_prefix}/baz/quux.jpg)"
        expect_wrapped_rule :section, /^background:\s+url\(data:image\/png;base64,/
      end

      allow_additional_assets!
    end)
  end

  it "should let you add SASS imports in a sane, shared location, and make them available wherever" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/shared_imports.rb' do
        expect_wrapped_rule :p, 'color: #a1a1a1'
        expect_wrapped_rule :div, 'color: #b2b2b2'
      end

      allow_additional_assets!
    end)
  end
end
