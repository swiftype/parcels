class Views::BasicRailsSpec::AlongsideAndInline < Views::Widgets::Base
  css %{
    p { color: green; }
  }

  def content
    p "hello, world"
  end
end
