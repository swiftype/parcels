describe "Parcels Rails basic support", :type => :rails do
  uses_rails_with_template :basic_rails_spec

  it "should at least have a working Rails server" do
    expect_match("simple_css", /hello, world/)
  end

  it "should wrap a simple widget in a class" do
    expect_match("simple_css", /<p class="parcels_class__views__basic_rails_spec__simple_css">hello, world<\/p>/)
  end

  it "should contain the CSS in application.css due to the 'require_parcels' directive" do
    data = rails_server.get("assets/application.css")
    expect(data).to match(/xxx/i)
  end

  it "should use Rails' asset search path for Sass @import"
  it "should support other features of sass-rails"
  it "should configure its SASS engine the same way that Rails does"

  it "should, by default, use the other features of the asset pipeline, like compression, just like Rails does"
  it "should allow using ERb in CSS if desired"
  it "should allow using other asset-pipeline engines (extensions) if desired"

  describe "dynamism support" do
    it "should allow changing inline CSS for a widget"
    it "should allow changing alongside CSS for a widget"
    it "should allow adding inline CSS for a widget"
    it "should allow removing inline CSS for a widget"
    it "should allow adding alongside CSS for a widget"
    it "should allow removing alongside CSS for a widget"

    it "should allow adding a file used by @import"
    it "should allow changing a file used by @import"
  end
end
