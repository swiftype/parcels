class Views::DevelopmentModeRailsSpec::BasicWidgetWithInlineAndAlongsideParcels < Views::Widgets::Base
  css %{
    p { color: green; }
  }

  def content
    p "hello, world!"
  end
end
