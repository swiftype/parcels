class Views::SassRailsSpec::ImportDirectory < Views::Widgets::Base
  css %{
    p { background: url(asset-path('foo/bar.jpg')); }
    div { background: url(asset-url('bar/baz.png')); }
  }

  def content
    text "hello, world"
  end
end
