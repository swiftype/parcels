describe "Parcels Rails SASS support", :type => :rails do
  uses_rails_with_template :sass_rails_spec

  it "should use Rails' asset search path for Sass @import in inline CSS" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/sass_rails_spec/default_sass_import.rb' do
        expect_wrapped_rule :p, 'color: #afedcb'
        expect_wrapped_rule :div, 'color: #0b1c2d'
        expect_wrapped_rule :span, 'color: #9a8b7c'
      end
    end)

    expect_match("default_sass_import", /XXX/)
  end

  it "should let you change Rails' asset search path, and use that for Sass @import"
  it "should support other features of sass-rails"
  it "should configure its SASS engine the same way that Rails does"
  it "should let you add SASS imports in a sane, shared location, and make them available wherever"
end
