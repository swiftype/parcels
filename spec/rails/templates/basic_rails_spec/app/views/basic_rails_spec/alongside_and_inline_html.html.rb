class Views::BasicRailsSpec::AlongsideAndInlineHtml < Views::Widgets::Base
  css %{
    p { color: yellow; }
  }

  def content
    p "hello, world"
  end
end
