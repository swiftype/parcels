class Views::DevelopmentModeRailsSpec::ChangingInlineCss < Views::Widgets::Base
  css %{
    p { color: green; }
  }

  def content
    p "hello, world!"
  end
end
