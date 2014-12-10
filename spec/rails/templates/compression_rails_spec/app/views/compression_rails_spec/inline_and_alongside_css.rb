class Views::CompressionRailsSpec::InlineAndAlongsideCss < Views::Widgets::Base
  css %{
    p { color: green; }
  }

  def content
    p "hello, world"
  end
end
