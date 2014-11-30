require 'spec/parsing/rails_asset'

module NewRailsHelpers
  def rails_asset(name, the_rails_server = nil)
    the_rails_server ||= rails_server
    ::Spec::Parsing::RailsAsset.new(the_rails_server, name)
  end

  def compiled_rails_asset(name, the_rails_server = nil)
    ::Spec::Parsing::CompiledAsset.new(rails_asset(name, the_rails_server))
  end

  def expected_rails_asset(subpath, the_rails_server = nil, &block)
    the_rails_server ||= rails_server
    ::Spec::Expected::ExpectedAsset.new("#{the_rails_server.rails_root}/app", subpath, &block)
  end

  def rails_assets(the_rails_server = nil, &block)
    the_rails_server ||= rails_server
    ::Spec::Expected::ExpectedAssetSet.new("#{the_rails_server.rails_root}/app", &block)
  end
end
