class Views::SassRailsSpec::AddedAssetPath < Views::Widgets::Base
  css %{
    @import "twenty";
    p { color: $mycolor20; }
  }

  def content
    text "hello, world"
  end
end
