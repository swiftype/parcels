class Views::SassRailsSpec::ImportDirectory < Views::Widgets::Base
  css %{
    @import "the_import_dir_1/*";
    p { color: $the_import_dir_1_color_1; }
    div { color: $the_import_dir_1_color_2; }
  }

  def content
    text "hello, world"
  end
end
