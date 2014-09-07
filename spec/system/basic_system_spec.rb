require 'fileutils'

require 'sprockets'
require 'parcels'

describe "Parcels basic operations" do
  class FileDefinition
    def initialize(spec, example)
      @spec = spec
      @example = example
      @files = { }
    end

    def file(subpath, contents = nil, &block)
      contents ||= block.call
      contents = $2 if contents =~ /^(\s*\n)*(.*?)(\s\n)*$/mi
      files[subpath] = contents
    end

    def create!
      files.each do |subpath, contents|
        full_path = File.join(spec.this_example_root(example), subpath)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.open(full_path, 'w') { |f| f << contents }
      end
    end

    private
    attr_reader :spec, :example, :files
  end

  def path(*path_components)
    File.expand_path(File.join(*path_components))
  end

  def extant_directory(*path_components)
    out = path(*path_components)
    FileUtils.mkdir_p(out)
    out
  end

  def clean_directory(*path_components)
    p = path(*path_components)
    FileUtils.rm_rf(p)
    FileUtils.mkdir_p(p)
    p
  end

  def gem_root
    @gem_root ||= extant_directory(File.dirname(File.dirname(__FILE__)))
  end

  def tempdir_root
    @tempdir_root ||= extant_directory(gem_root, 'tmp')
  end

  def this_spec_name
    @this_spec_name ||= begin
      name = self.class.name
      name = $1 if name =~ /::([^:]+)$/i
      name.strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
    end
  end

  def this_spec_root
    @this_spec_root ||= extant_directory(tempdir_root, this_spec_name)
  end

  def this_example_name(example)
    @this_example_name ||= example.metadata[:full_description].strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
  end

  def this_example_root(example)
    @this_example_root ||= clean_directory(this_spec_root, this_example_name(example))
  end

  def files(example, &block)
    @file_definition ||= FileDefinition.new(self, example)
    @file_definition.instance_eval(&block)
    @file_definition.create!
  end

  it "should aggregate a simple standalone fragment into one aggregate file" do |ex|
    files(ex) {
      file 'assets/basic.css', %w{
        /*
         *= require_parcels fragments
         */
        FIN
      }

      file 'fragments/one.css', %w{
        p { color: red; }
      }
    }

    sprockets_env = ::Sprockets::Environment.new(this_example_root(ex))
    sprockets_env.append_path 'assets'
    ::Parcels.view_paths = [ path('fragments') ]

    asset = sprockets_env.find_asset('basic')
    $stderr.puts "ASSET: #{asset.class.name}"
    $stderr.puts "source: #{asset.source}"
    $stderr.puts "body: #{asset.body}"
  end
end
