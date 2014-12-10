class Views::SassRailsSpec::SharedImports < Views::Widgets::ImportBase
  css %{
    p { color: $sid1_color1; }
    div { color: $sid1_color2; }
  }

  def content
    text "hello, world"
  end
end
