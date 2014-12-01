class Views::DevelopmentModeRailsSpec::AddingImportFile < Views::Widgets::Base
  css %{
    @import "one";
    p { color: $mycolor1; }
  }

  def content
    p "hello, world!"
  end
end
