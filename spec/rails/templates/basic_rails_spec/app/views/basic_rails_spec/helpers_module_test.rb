class Views::BasicRailsSpec::HelpersModuleTest < Views::Widgets::Base
  include Views::BasicRailsSpec::HelpersModule

  css %{
    p { color: green; }
  }

  def content
    text "and it is "
    my_helper
    text " tada!"
  end
end
