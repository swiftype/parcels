module ParcelsRailsHelpers
  def rails_server_project_root
    @rails_server_project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def rails_server_additional_gemfile_lines
    [
      "gem 'fortitude', \">= 0.9.2\"",
      "gem 'parcels', :path => '#{rails_server_project_root}'"
    ]
  end

  def rails_server_implicit_template_paths
    [ :base ]
  end

  def rails_server_default_version
    ENV['PARCELS_SPECS_RAILS_VERSION']
  end
end
