describe "Parcels Rails basic support", :type => :rails do
  uses_rails_with_template :basic_rails_spec

  it "should at least have a working Rails server" do
    expect_match("simple_css", /hello, world/)
  end

  it "should wrap a simple widget in a class" do
    expected_class = expected_rails_asset('views/basic_rails_spec/simple_css.rb').parcels_wrapping_class
    expect_match("simple_css", /<p class="#{Regexp.escape(expected_class)}">hello, world<\/p>/)
  end

  it "should contain the CSS in application.css due to the 'require_parcels' directive" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/basic_rails_spec/simple_css.rb' do
        expect_wrapped_rule nil, 'color: green'
      end
    end)
  end

  it "should allow precompiling assets with 'rake'" do
    rails_server.run_command_in_rails_root!("rake assets:precompile")

    asset = precompiled_rails_asset('application.css')
    asset.should_match(rails_assets do
      asset 'views/basic_rails_spec/simple_css.rb' do
        expect_wrapped_rule nil, 'color: green'
      end
    end)
  end

  it "should not pick up alongside files if there is no corresponding widget class"

  it "should use Rails' asset search path for Sass @import"
  it "should let you change Rails' asset search path, and use that for Sass @import"
  it "should support other features of sass-rails"
  it "should configure its SASS engine the same way that Rails does"

  it "should, by default, use the other features of the asset pipeline, like compression, just like Rails does"
  it "should allow using ERb in CSS if desired"
  it "should allow using other asset-pipeline engines (extensions) if desired"
end
