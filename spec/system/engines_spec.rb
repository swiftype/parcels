describe "Parcels engines support", :type => :system do
  context "with CSS containing ERb" do
    let(:css_with_erb) { 'p { background-image: url("foo-<%= 3 * 7 %>"); }' }
    let(:css_options) { nil }
    let(:css_arguments) do
      if css_options
        [ css_with_erb, :options => css_options ]
      else
        [ css_with_erb ]
      end
    end
    let(:class_text) { nil }

    def expect_erb_not_processed
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'background-image: url("foo-<%= 3 * 7 %>")'
        end
      end)
    end

    def expect_erb_processed
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'background-image: url("foo-21")'
        end
      end)
    end

    before :each do
      the_css_arguments = css_arguments
      the_class_text = class_text

      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          css *the_css_arguments

          if the_class_text
            class_text the_class_text
          end
        end
      }
    end

    it "should not, by default, process the ERb" do
      expect_erb_not_processed
    end

    context "when passed an option containing a string starting with a dot" do
      let(:css_options) { { :engines => '.erb' } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed an option containing a string not starting with a dot" do
      let(:css_options) { { :engines => 'erb' } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed an option containing a symbol" do
      let(:css_options) { { :engines => :erb } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed an option with an array of a string starting with a dot" do
      let(:css_options) { { :engines => [ '.erb' ] } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed an option with an array of a string not starting with a dot" do
      let(:css_options) { { :engines => [ 'erb' ] } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed an option with an array of a symbol" do
      let(:css_options) { { :engines => [ '.erb' ] } }
      it "should process the ERb" do
        expect_erb_processed
      end
    end

    context "when passed #css_options" do
      let(:class_text) do
        %{  css_options :engines => '.erb' }
      end

      it "should process engines as specified" do
        expect_erb_processed
      end

      context "when also passed options directly" do
        let(:css_options) { { :engines => [ ] } }

        it "should let the passed options override the class-level ones" do
          expect_erb_not_processed
        end
      end
    end

  end

  it "should properly inherit #css_options from superclasses" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/parent_widget' do
        class_text %{  css_options :engines => '.erb'}
      end

      widget 'views/child_widget', :superclass => 'Views::ParentWidget' do
        requires %{views/parent_widget}
        css %{p { background-image: url("foo-<%= 7 * 3 %>"); }}
      end
    }

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/child_widget.rb' do
        expect_wrapped_rule :p, 'background-image: url("foo-21")'
      end
    end)
  end

  context "alongside files" do
    it "should not process ERb, by default" do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget'
        file 'views/my_widget.css', %{
          p { background-image: url("foo-<%= 7 * 3 %>"); }
        }
      }

      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.css' do
          expect_wrapped_rule :p, 'background-image: url("foo-<%= 7 * 3 %>")'
        end
      end)
    end

    it "should use engines specified by #css_options" do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          class_text %{  css_options :engines => '.erb'}
        end
        file 'views/my_widget.css', %{
          p { background-image: url("foo-<%= 7 * 3 %>"); }
        }
      }

      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.css' do
          expect_wrapped_rule :p, 'background-image: url("foo-21")'
        end
      end)
    end

    it "should properly inherit #css_options from superclasses" do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/parent_widget' do
          class_text %{  css_options :engines => '.erb'}
        end

        widget 'views/child_widget', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
        end

        file 'views/child_widget.css', %{
          p { background-image: url("foo-<%= 7 * 3 %>"); }
        }
      }

      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/child_widget.css' do
          expect_wrapped_rule :p, 'background-image: url("foo-21")'
        end
      end)
    end
  end

  it "should support multiple Sprockets engines (stringification, then ERb)" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { background-image: url("<\\\#{'%'}= 7 * 3 %>"); }
        }, :options => { :engines => '.erb.str' }
      end
    }

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'background-image: url("21")'
      end
    end)
  end

  it "should support multiple Sprockets engines (ERb, then stringification)" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { background-image: url("<\\\#{'%'}= 7 * 3 %>"); }
        }, :options => { :engines => '.str.erb' }
      end
    }

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'background-image: url("<%= 7 * 3 %>")'
      end
    end)
  end
end
