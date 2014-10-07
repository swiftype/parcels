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

    def expect_erb_not_processed
      expect_css_content_in('basic',
        'views/my_widget.rb' => {
          widget_scoped(:p) => "background-image: url(\"foo-<%= 3 * 7 %>\")"
        })
    end

    def expect_erb_processed
      expect_css_content_in('basic',
        'views/my_widget.rb' => {
          widget_scoped(:p) => "background-image: url(\"foo-21\")"
        })
    end

    before :each do
      the_css_arguments = css_arguments

      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          css *the_css_arguments
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

    it "should allow overriding #css_engines to specify engines"
    it "should have :engines take precedence over #css_engines"
    it "should properly inherit #css_engines from superclasses"
  end

  context "alongside files" do
    it "should use engines specified by #css_engines"
    it "should properly inherit #css_engines from superclasses"
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

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "background-image: url(\"21\")"
      })
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

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        widget_scoped(:p) => "background-image: url(\"<%= 7 * 3 %>\")"
      })
  end
end
