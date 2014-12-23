 describe "Parcels ad-hoc development mode support", :type => :system do
  # Rails' development mode (which is really just ActiveSupport's class-unloading support) does the right thing:
  # it actually completely unloads every class after each request cycle, removing the old class definition from memory
  # (well, modulo GC, but you get the idea). This means that if you remove or change CSS definitions in a widget class,
  # they will genuinely be gone/changed on the next iteration, and Parcels will behave correctly.
  #
  # Some programs, however -- Middleman is where I discovered this issue -- simply re-evaluate templates in development
  # mode. For "normal" templates (e.g., ERb, HAML, whatever), this works just fine. But, with Parcels, this can be an
  # issue: the widget class definition itself just gets re-processed, and, if you've removed CSS from the class or
  # changed that CSS, the class will now have both the new *and* the old definitions around. This causes really
  # frustrating chaos as your changes seem to sometimes, but not always, get picked up, depending on whether the new
  # CSS actually overrides the old or depends on the old not being present (like removing a CSS selector, etc.).
  #
  # Unfortunately, due to the way Ruby classes work, there's no one "right way" around this issue: Ruby doesn't have
  # any kind of callback saying "class X is getting defined", because re-opening classes means that there's really no
  # objective way of deciding when that's true. Instead, we check for declarations of CSS on a widget class where the
  # line number is equal to, or before, the line numbers of other CSS declarations, and remove those other declarations
  # when this happens.
  #
  # This doesn't catch every single case -- if you simultaneously change CSS and add one or more lines above the .css
  # call in a class, for example, it will be missed -- but it catches the vast majority of cases, and is uniformly an
  # improvement to the system.
  #
  # This is a test to make sure that works.
  context "with a widget class that gets changed" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          css %{
            p { color: red; }
          }
          css %{
            span { color: green; }
          }
        end
      }
    end

    it "should handle the case where the CSS changes" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb', :sequencing => true do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/my_widget.rb', :sequencing => true do
          expect_wrapped_rule :span, 'color: green'
        end
      end)

      widget_path = File.join(this_example_root, 'views', 'my_widget.rb')
      expect(File.exist?(widget_path)).to be

      File.open(widget_path, 'w') do |f|
        f << <<-EOS
class Views::MyWidget < ::Spec::Fixtures::WidgetBase
  css %{
    p { color: yellow; }
  }
end
EOS
      end

      old_sprockets_env = sprockets_env
      reset_sprockets_env!

      load(widget_path)
      expect(sprockets_env.object_id).not_to eq(old_sprockets_env.object_id)

      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'color: yellow'
        end
      end)
    end
  end
end
