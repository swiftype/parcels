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

  def render_file_asset(subpath, args = { }, options = { })
    subpath = $1 if subpath =~ %r{^(.*?)\.[^/]+$}i
    full_path = File.join(files_root, subpath)
    full_path += ".rb" unless full_path =~ /\.rb\s*$/i
    widget_class = Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => files_root)
    html = widget_class.new(args).to_html
    out = Nokogiri::HTML(html)
    out = out.xpath('/html/body') if options.fetch(:extract_body_contents, true)
    out
  end
end
