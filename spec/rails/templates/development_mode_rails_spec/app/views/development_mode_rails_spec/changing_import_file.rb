class Views::DevelopmentModeRailsSpec::ChangingImportFile < Views::Widgets::Base
  css %{
    @import "changingone";
    p { color: $changing1; }
  }

  def content
    p "hello, world!"
  end
end
