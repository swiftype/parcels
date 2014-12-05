class Views::SassRailsSpec::ImportViewRelativeDirectory < Views::Widgets::Base
  css %{
    @import "vr_import_dir_1/*";
    p { color: $vr_import_dir_1_color_1; }
    div { color: $vr_import_dir_1_color_2; }
  }

  def content
    text "hello, world"
  end
end
