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

      asset 'views/sass_rails_spec/default_sass_import.css' do
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

      asset 'views/sass_rails_spec/added_asset_path.css' do
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

      asset 'views/sass_rails_spec/other_features.css' do
        expect_wrapped_rule :div, 'color: #040608'
      end

      allow_additional_assets!
    end)
  end

  it "should configure its SASS engine the same way that Rails does"
  it "should let you add SASS imports in a sane, shared location, and make them available wherever"
end
