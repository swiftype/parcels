describe "Parcels Rails development-mode support", :type => :rails do
  uses_rails_with_template :development_mode_rails_spec, :rails_env => :development

  it "should include all parcels in application.css if you ask it to" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/basic_widget_with_inline_and_alongside_parcels.css' do
        expect_wrapped_rule :div, 'color: blue'
      end

      asset 'views/development_mode_rails_spec/basic_widget_with_inline_and_alongside_parcels.rb' do
        expect_wrapped_rule :p, 'color: green'
      end

      allow_additional_assets!
    end)
  end

  it "should allow changing inline CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_inline_css.rb' do
        expect_wrapped_rule :p, 'color: green'
      end
      allow_additional_assets!
    end)

    path = File.join(rails_server.rails_root, 'app/views/development_mode_rails_spec/changing_inline_css.rb')
    contents = File.read(path)
    if contents =~ %r{\A(.*)color: green(.*)\Z}mi
      new_contents = "#{$1}color: red#{$2}"
    else
      raise "This spec is broken; contents are:\n#{contents}"
    end

    File.open(path, 'w') { |f| f << new_contents }
    sleep 1
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_inline_css.rb' do
        expect_wrapped_rule :p, 'color: red'
      end
      allow_additional_assets!
    end)
  end

  it "should allow changing alongside CSS for a widget"
  it "should allow adding inline CSS for a widget"
  it "should allow removing inline CSS for a widget"
  it "should allow adding alongside CSS for a widget"
  it "should allow removing alongside CSS for a widget"

  it "should allow adding a file used by @import"
  it "should allow changing a file used by @import"
end
