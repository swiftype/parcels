class Views::DevelopmentModeRailsSpec::ChangingPrefixImportedFile < Views::ImportBase
  css %{p { color: $import_dir_color_1; }}

  def content
    p "hello, world!"
  end
end
