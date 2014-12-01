class Views::SassRailsSpec::DefaultSassImport < Views::Widgets::Base
  css %{
    @import "one";
    @import "two";
    @import "three";
    p { color: $mycolor1; }
    div { color: $mycolor2; }
    span { color: $mycolor3; }
  }

  def content
    text "hello, world"
  end
end
