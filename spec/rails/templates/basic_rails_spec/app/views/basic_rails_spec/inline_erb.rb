class Views::BasicRailsSpec::InlineErb < Views::Widgets::Base
  css %{
    p { background-image: url("foo-<%= 3 * 7 %>"); }
  }, :engines => '.erb'

  def content
    p "hello, world"
  end
end
