class Views::BasicRailsSpec::SimpleCss < Views::Widgets::Base
  css %{
    color: green;
  }

  def content
    p "hello, world"
  end
end
