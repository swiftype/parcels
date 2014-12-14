require 'fileutils'

describe "Parcels Rails development-mode support", :type => :rails do
  uses_rails_with_template :development_mode_rails_spec, :rails_env => :development

  it "should include all parcels in application.css if you ask it to" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/basic_widget_with_inline_and_alongside_parcels.pcss' do
        expect_wrapped_rule :div, 'color: blue'
      end

      asset 'views/development_mode_rails_spec/basic_widget_with_inline_and_alongside_parcels.rb' do
        expect_wrapped_rule :p, 'color: green'
      end

      allow_additional_assets!
    end)
  end

  def wait_until_passes(options = { }, &block)
    timeout = options[:timeout] || 3.seconds
    interval = options[:interval] || 0.5.seconds

    timeout_time = Time.now + timeout
    passed = false
    attempt_count = 0
    last_exception = nil

    while (! passed) && (Time.now < timeout_time)
      begin
        block.call
        passed = true
      rescue Interrupt => i
        raise
      rescue => e
        attempt_count += 1
        last_exception = e
        sleep interval.to_f
      end
    end

    unless passed
      raise "Block failed, even after #{attempt_count} tries and #{timeout} seconds! Last exception was:\n#{e.message} (#{e.class.name}):\n    #{e.backtrace.join("\n    ")}"
    end
  end

  def sleep_before_change
    start_time = Time.now.to_i
    while Time.now.to_i == start_time
      sleep 0.05
    end
  end

  def substitute_at_path(subpath, from_what, to_what)
    path = File.join(rails_server.rails_root, subpath)
    contents = File.read(path)
    if contents =~ %r{\A(.*)#{Regexp.escape(from_what)}(.*)\Z}mi
      new_contents = "#{$1}#{to_what}#{$2}"
    else
      raise "This spec is broken; we were looking for #{from_what.inspect}, but contents are:\n#{contents}"
    end

    sleep_before_change

    File.open(path, 'w') { |f| f << new_contents }
  end

  def add_at_path(subpath, what)
    path = File.join(rails_server.rails_root, subpath)
    raise "Path should not exist, but does: #{path.inspect}" if File.exist?(path)

    sleep_before_change

    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f << what }
  end

  def remove_at_path(subpath)
    path = File.join(rails_server.rails_root, subpath)
    raise "Path should exist, but doesn't: #{path.inspect}" unless File.exist?(path)

    sleep_before_change

    File.delete(path)
  end

  it "should allow changing inline CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_inline_css.rb' do
        expect_wrapped_rule :p, 'color: green'
      end
      allow_additional_assets!
    end)

    substitute_at_path('app/views/development_mode_rails_spec/changing_inline_css.rb', 'color: green', 'color: red')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/changing_inline_css.rb' do
          expect_wrapped_rule :p, 'color: red'
        end
        allow_additional_assets!
      end)
    end
  end

  it "should allow changing alongside CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_alongside_css.pcss' do
        expect_wrapped_rule :p, 'color: blue'
      end
      allow_additional_assets!
    end)

    substitute_at_path('app/views/development_mode_rails_spec/changing_alongside_css.pcss', 'color: blue', 'color: purple')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/changing_alongside_css.pcss' do
          expect_wrapped_rule :p, 'color: purple'
        end
        allow_additional_assets!
      end)
    end
  end

  it "should allow adding inline CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset_must_not_be_present('views/development_mode_rails_spec/adding_inline_css.rb')
      allow_additional_assets!
    end)

    substitute_at_path('app/views/development_mode_rails_spec/adding_inline_css.rb', '# CSS_WILL_GO_HERE', "css %{p { color: yellow } }")

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/adding_inline_css.rb' do
          expect_wrapped_rule :p, 'color: yellow'
        end
        allow_additional_assets!
      end)
    end
  end

  it "should allow removing inline CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/removing_inline_css.rb' do
        expect_wrapped_rule :p, 'color: magenta'
      end
      allow_additional_assets!
    end)

    substitute_at_path('app/views/development_mode_rails_spec/removing_inline_css.rb', 'css %{p { color: magenta; }}', '# NO MORE CSS!')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset_must_not_be_present('views/development_mode_rails_spec/removing_inline_css.rb')
        allow_additional_assets!
      end)
    end
  end

  it "should allow adding alongside CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset_must_not_be_present('views/development_mode_rails_spec/adding_alongside_css.pcss')
      allow_additional_assets!
    end)

    add_at_path('app/views/development_mode_rails_spec/adding_alongside_css.pcss', "p { color: cyan; }")

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/adding_alongside_css.pcss' do
          expect_wrapped_rule :p, 'color: cyan'
        end
        allow_additional_assets!
      end)
    end
  end

  it "should allow removing alongside CSS for a widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/removing_alongside_css.pcss' do
        expect_wrapped_rule :p, 'color: yellow'
      end
      allow_additional_assets!
    end)

    remove_at_path('app/views/development_mode_rails_spec/removing_alongside_css.pcss')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset_must_not_be_present('views/development_mode_rails_spec/removing_alongside_css.pcss')
        allow_additional_assets!
      end)
    end
  end

  it "should allow changing a file used by @import" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_import_file.rb' do
        expect_wrapped_rule :p, 'color: #123456'
      end

      asset 'views/development_mode_rails_spec/changing_import_file.pcss' do
        expect_wrapped_rule :div, 'color: #234567'
      end

      allow_additional_assets!
    end)

    substitute_at_path('app/assets/stylesheets/changingone.scss', '123456', '456789')
    substitute_at_path('app/assets/stylesheets/changingtwo.scss', '234567', '567890')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/changing_import_file.rb' do
          expect_wrapped_rule :p, 'color: #456789'
        end

        asset 'views/development_mode_rails_spec/changing_import_file.pcss' do
          expect_wrapped_rule :div, 'color: #567890'
        end

        allow_additional_assets!
      end)
    end
  end

  it "should allow changing a file imported via the CSS prefix, and respect that change" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/changing_prefix_imported_file.rb' do
        expect_wrapped_rule :p, 'color: #abcdef'
      end

      asset 'views/development_mode_rails_spec/changing_prefix_imported_file.pcss' do
        expect_wrapped_rule :div, 'color: #abcdef'
      end

      allow_additional_assets!
    end)

    substitute_at_path('app/assets/stylesheets/import_dir/import_dir_ss_1.scss', 'abcdef', 'fedcba')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/changing_prefix_imported_file.rb' do
          expect_wrapped_rule :p, 'color: #fedcba'
        end

        asset 'views/development_mode_rails_spec/changing_prefix_imported_file.pcss' do
          expect_wrapped_rule :div, 'color: #fedcba'
        end

        allow_additional_assets!
      end)
    end
  end

  it "should allow adding a widget, along with an alongside file" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset_must_not_be_present('views/development_mode_rails_spec/added_widget.rb')
      asset_must_not_be_present('views/development_mode_rails_spec/added_widget.pcss')
      allow_additional_assets!
    end)

    add_at_path('app/views/development_mode_rails_spec/added_widget.rb', <<-EOS)
class Views::DevelopmentModeRailsSpec::AddedWidget < Views::Widgets::Base
  css %{
    p { color: blue; }
  }

  def content
    p "nothing here"
  end
end
EOS
    add_at_path('app/views/development_mode_rails_spec/added_widget.pcss', <<-EOS)
div { color: purple; }
EOS

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset 'views/development_mode_rails_spec/added_widget.rb' do
          expect_wrapped_rule :p, 'color: blue'
        end

        asset 'views/development_mode_rails_spec/added_widget.pcss' do
          expect_wrapped_rule :div, 'color: purple'
        end

        allow_additional_assets!
      end)
    end
  end

  it "should allow removing a widget, along with an alongside file" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/development_mode_rails_spec/removing_widget.rb' do
        expect_wrapped_rule :p, 'color: cyan'
      end

      asset 'views/development_mode_rails_spec/removing_widget.pcss' do
        expect_wrapped_rule :div, 'color: green'
      end

      allow_additional_assets!
    end)

    remove_at_path('app/views/development_mode_rails_spec/removing_widget.rb')
    remove_at_path('app/views/development_mode_rails_spec/removing_widget.pcss')

    wait_until_passes do
      compiled_rails_asset('application.css').should_match(rails_assets do
        asset_must_not_be_present('views/development_mode_rails_spec/removing_widget.rb')
        asset_must_not_be_present('views/development_mode_rails_spec/removing_widget.pcss')
        allow_additional_assets!
      end)
    end
  end
end
