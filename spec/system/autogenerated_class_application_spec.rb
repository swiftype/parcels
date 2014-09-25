describe "Parcels autogenerated class application", :type => :system do
  it "should apply the autogenerated class to the outermost element of a widget" do
    files {
      widget 'views/my_widget' do
        css "p { color: red; }"

        content %{
          p "hello"
        }
      end
    }

    doc = rendered_widget_content('views/my_widget')

    expect(classes_from(doc, 'p')).to eq([ widget_outer_element_class_from_subpath('views/my_widget') ])
  end

  it "should name that class correctly, using double underscores for path separators and single in place of CamelCase" do
    files {
      file 'lib/foo.rb', %{
        module Views::Foo
        end
      }

      widget 'views/foo/my_widget' do
        requires 'lib/foo'
        css "p { color: red; }"

        content %{
          p "hello"
        }
      end
    }

    doc = rendered_widget_content('views/foo/my_widget')
    classes = classes_from(doc, 'p')

    expect(classes.length).to eq(1)
    expect(classes[0]).to match(/views__foo__my_widget/)
  end

  it "should apply the autogenerated class to multiple outermost elements of a widget" do
    files {
      widget 'views/my_widget' do
        css "p { color: red; }"

        content %{
          p "hello"
          span "goodbye"
        }
      end
    }

    doc = rendered_widget_content('views/my_widget')

    expect(classes_from(doc, 'p')).to eq([ widget_outer_element_class_from_subpath('views/my_widget') ])
    expect(classes_from(doc, 'span')).to eq([ widget_outer_element_class_from_subpath('views/my_widget') ])
  end

  it "should not apply the autogenerated class to elements that aren't outermost" do
    files {
      widget 'views/my_widget' do
        css "p { color: red; }"

        content %{
          div {
            p "hello"
            p "there"
            p {
              span "goodbye"
            }
          }
        }
      end
    }

    doc = rendered_widget_content('views/my_widget')

    expect(classes_from(doc, 'div')).to eq([ widget_outer_element_class_from_subpath('views/my_widget') ])
    expect(classes_from(doc, 'div/p[1]')).to be_empty
    expect(classes_from(doc, 'div/p[2]')).to be_empty
    expect(classes_from(doc, 'div/p[3]')).to be_empty
    expect(classes_from(doc, 'div/p/span')).to be_empty
  end

  it "should not apply any classes if there is no CSS for a widget" do
    files {
      widget 'views/my_widget' do
        content %{
          p "hello"
        }
      end
    }

    doc = rendered_widget_content('views/my_widget')

    expect(classes_from(doc, 'p')).to be_empty
  end

  it "should apply classes if there's CSS in an alongside file"

  it "should apply autogenerated classes from a parent widget, too" do
    files {
      widget 'views/parent_widget' do
        css "p { color: red; }"

        content %{
          p "hello"
        }
      end

      widget 'views/child_widget', :superclass => 'Views::ParentWidget' do
        requires %{views/parent_widget}
        css "p { color: blue; }"

        content %{
          super
          p "goodbye"
        }
      end
    }

    doc = rendered_widget_content("views/child_widget")

    expect(classes_from(doc, 'p[1]').sort).to eq([
      widget_outer_element_class_from_subpath('views/parent_widget'),
      widget_outer_element_class_from_subpath('views/child_widget')
    ].sort)
  end

  it "should apply autogenerated classes from a whole parent hierarchy"
  it "should not apply autogenerated classes from a widget in the hierarchy for which there's no CSS"

  it "should stop applying autogenerated classes at a parent widget that isn't enabled for Parcels"
end
