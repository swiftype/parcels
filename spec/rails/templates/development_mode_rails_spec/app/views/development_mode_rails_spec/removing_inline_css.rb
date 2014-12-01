class Views::DevelopmentModeRailsSpec::RemovingInlineCss < Views::Widgets::Base
  css %{p { color: magenta; }}

  def content
    p "hello, world!"
  end
end
