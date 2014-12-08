class Views::SassRailsSpec::AssetUrl < Views::Widgets::Base
  css %{
    p { background: url(asset-path('foo/bar.jpg')); }
    div { background: asset-url('bar/baz.png'); }
  }

  def content
    text "hello, world"
  end
end
