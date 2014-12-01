class Views::SassRailsSpec::OtherFeatures < Views::Widgets::Base
  css %{
    p { color: #010203 + #040506; }
  }

  def content
    text "hello, world"
  end
end
