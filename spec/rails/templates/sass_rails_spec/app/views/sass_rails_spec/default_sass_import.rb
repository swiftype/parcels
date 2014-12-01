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
    text "Rails asset paths:\n  #{Rails.application.config.assets.paths.join("\n  ")}"
  end
end
