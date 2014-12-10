class Views::BasicRailsSpec::MultipleEngines < Views::Widgets::Base
  css_options :engines => '.erb.str'

  css 'p { background-image: url("<#{"%"}= 7 * 3 %>"); }'

  def content
    p "hello, world"
  end
end
