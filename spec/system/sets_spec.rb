describe "Parcels sets", :type => :system do
  context "with widgets in various sets" do
    before :each do
      files {
        file 'assets/one.css', %{
          //= require_parcels
        }

        file 'assets/two.css', %{
          //= require_parcels aaa
        }

        file 'assets/three.css', %{
          //= require_parcels bbb
        }

        file 'assets/four.css', %{
          //= require_parcels aaa bbb
        }

        file 'assets/five.css', %{
          //= require_parcels  aaa,   bbb
        }

        widget 'views/parent_widget' do
          css %{
            p { color: red; }
          }

          sets :aaa
        end

        widget 'views/widget_one', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{div { color: green; }}
        end

        file 'views/widget_one.css', %{
          div.a { color: green; }
        }

        widget 'views/widget_two', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{span { color: blue; }}
          sets :bbb
        end

        file 'views/widget_two.css', %{
          span.a { color: blue; }
        }

        widget 'views/widget_three', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{em { color: yellow; }}
          sets :aaa, :bbb
        end

        file 'views/widget_three.css', %{
          em.a { color: yellow; }
        }

        widget 'views/widget_four', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{strong { color: cyan; }}
          sets nil
        end

        file 'views/widget_four.css', %{
          strong.a { color: cyan; }
        }

        widget 'views/widget_five', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{h1 { color: magenta; }}
          sets :aaa
        end

        file 'views/widget_five.css', %{
          h1.a { color: magenta; }
        }

        widget 'views/widget_six', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{h2 { color: black; }}
          sets_block %{do |klass|
  if klass.name =~ /seven/i
    [ :aaa, :bbb ]
  else
    :bbb
  end
end
}
        end

        file 'views/widget_six.css', %{
          h2.a { color: black; }
        }

        widget 'views/widget_seven', :superclass => 'Views::WidgetSix' do
          requires %{views/widget_six}
          css %{h3 { color: white; }}
        end

        file 'views/widget_seven.css', %{
          h3.a { color: white; }
        }
      }
    end

    it "should put everything in if you don't specify any sets" do
      compiled_sprockets_asset('one').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.css' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.css' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.css' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_four.rb' do
          expect_wrapped_rule :strong, 'color: cyan'
        end

        asset 'views/widget_four.css' do
          expect_wrapped_rule :'strong.a', 'color: cyan'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.css' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.css' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.css' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end

    it "should put in just that one set if that's what you ask for" do
      compiled_sprockets_asset('two').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.css' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.css' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.css' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.css' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end

    it "should put in just the other set if that's what you ask for" do
      compiled_sprockets_asset('three').should_match(file_assets do
        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.css' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.css' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.css' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.css' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end

    it "should let you separate set names with a comma, and still work fine" do
      compiled_sprockets_asset('five').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.css' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.css' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.css' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.css' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.css' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.css' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end

    it "should put in both sets if you ask, but not things with no sets at all" do
      compiled_sprockets_asset('four').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.css' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.css' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.css' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.css' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.css' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.css' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end
  end
end
