require 'spec/expected/expected_asset_set'

module NewAssetHelpers
  def sprockets_asset(name, the_sprockets_env = nil)
    the_sprockets_env ||= sprockets_env
    ::Spec::Parsing::SprocketsAsset.new(the_sprockets_env, name)
  end

  def compiled_sprockets_asset(name, the_sprockets_env = nil)
    ::Spec::Parsing::CompiledAsset.new(sprockets_asset(name, the_sprockets_env))
  end

  def expected_file_asset(subpath, &block)
    ::Spec::Expected::ExpectedAsset.new(files_root, subpath, &block)
  end

  def file_assets(&block)
    ::Spec::Expected::ExpectedAssetSet.new(files_root, &block)
  end

  def expect_file_asset_in(compiled_asset_name, subpath, &block)
    compiled_sprockets_asset(compiled_asset_name).assert_matches!(expected_file_asset(subpath, &block))
  end
end
