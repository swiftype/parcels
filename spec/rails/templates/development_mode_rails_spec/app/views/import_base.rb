class Views::ImportBase < Views::Widgets::Base
  css_prefix %{
    @import "import_dir/*";
  }
end
