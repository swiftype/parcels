require 'fileutils'

require 'sprockets'
require 'parcels'

describe "Parcels basic operations" do
  it "should aggregate a simple standalone fragment into one aggregate file" do
    gem_root = File.expand_path(File.dirname(File.dirname(__FILE__)))
    tempdir_root = File.join(gem_root, 'tmp')
    spec_temp_root = File.join(tempdir_root, 'spec')
    this_spec_root = File.join(spec_temp_root, 'basic_system_spec')
    this_example_root = File.join(this_spec_root, 'basic-1')

    FileUtils.rm_rf(this_example_root)
    FileUtils.mkdir_p(this_example_root)

    assets_dir = File.join(this_example_root, 'assets')
    fragments_dir = File.join(this_example_root, 'fragments')

    FileUtils.mkdir_p(assets_dir)
    FileUtils.mkdir_p(fragments_dir)

    File.open(File.join(assets_dir, 'basic.css'), 'w') do |f|
      f.puts "/*"
      f.puts " *= require_parcels fragments"
      f.puts "*/"
      f.puts "FIN"
    end

    File.open(File.join(fragments_dir, 'one.css'), 'w') do |f|
      f.puts "p { color: red; }"
    end

    sprockets_env = ::Sprockets::Environment.new(this_example_root)
    sprockets_env.append_path 'assets'

    asset = sprockets_env.find_asset('basic')
    $stderr.puts "ASSET: #{asset.class.name}"
    $stderr.puts "source: #{asset.source}"
    $stderr.puts "body: #{asset.body}"
  end
end
