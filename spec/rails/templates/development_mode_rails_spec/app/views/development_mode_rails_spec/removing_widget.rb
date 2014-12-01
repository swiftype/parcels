class Views::DevelopmentModeRailsSpec::RemovingWidget < Views::Widgets::Base
  css %{
    p { color: cyan; }
  }

  def content
    p "hello, world!"
  end
end
