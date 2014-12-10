class Views::BasicRailsSpec::AlongsideErb < Views::Widgets::Base
  css_options :engines => '.erb'

  def content
    p "hello, world"
  end
end
