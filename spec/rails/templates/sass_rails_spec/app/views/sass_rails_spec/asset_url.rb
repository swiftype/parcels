class Views::SassRailsSpec::AssetUrl < Views::Widgets::Base
  if ::Rails.version =~ /^3/
    css %{
      p { background: url(asset-path('foo/bar.jpg', 'image')); }
      div { background: asset-url('bar/baz.png', 'image'); }
    }
  else
    css %{
      p { background: url(asset-path('foo/bar.jpg')); }
      div { background: asset-url('bar/baz.png'); }
    }
  end

  def content
    text "hello, world"
  end
end
