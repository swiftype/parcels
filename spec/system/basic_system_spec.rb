require 'fileutils'

require 'sprockets'
require 'parcels'

class ::SpecWidget < ::Fortitude::Widget
  doctype :html5

  def content
    text "spec_widget #{self.class.name} contents!"
  end
end

describe "Parcels basic operations" do
  class WidgetDefinition
    def initialize(class_name, superclass)
      @class_name = class_name
      @superclass = superclass
      @css = [ ]
    end

    def css(css_text)
      @css << css_text
    end

    def source_text
      text = [ "class #{class_name} < ::#{superclass}" ]
      @css.each do |css_text|
        text += [ "  css <<-EOS", css_text, "EOS" ]
      end
      text += [ "end" ]
      text.join("\n") + "\n"
    end

    private
    attr_reader :class_name, :superclass
  end

  class SpecFileSet
    def initialize(spec)
      @spec = spec
      @files = { }
      @widgets = { }
    end

    def file(subpath, contents = nil)
      contents = $2 if contents =~ /\A(\s*\n)*(.*?)(\s\n)*\Z/mi
      files[subpath] = contents
    end

    def widget(subpath, options = { }, &block)
      class_name = options[:class_name] || subpath.camelize
      superclass = options[:superclass] || ::SpecWidget
      superclass = superclass.name if superclass.kind_of?(Class)
      subpath += ".rb" unless subpath =~ /\.rb$/i

      widget_definition = WidgetDefinition.new(class_name, superclass)
      widget_definition.instance_eval(&block)

      @widgets[subpath] = widget_definition
    end

    def create!
      files.each do |subpath, contents|
        full_path = File.join(spec.this_example_root, subpath)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.open(full_path, 'w') { |f| f << contents }
      end

      widgets.each do |subpath, definition|
        full_path = File.join(spec.this_example_root, subpath)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.open(full_path, 'w') { |f| f << definition.source_text }
      end
    end

    private
    attr_reader :spec, :files, :widgets
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

  def this_example_name
    @this_example_name ||= this_example.metadata[:full_description].strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
  end

  def this_example_root
    @this_example_root ||= clean_directory(this_spec_root, this_example_name)
  end

  def files(&block)
    @file_definition ||= SpecFileSet.new(self)
    @file_definition.instance_eval(&block)
    @file_definition.create!
  end

  def new_sprockets_env(*args)
    ::Sprockets::Environment.new(*args)
  end

  before :each do |example|
    @this_example = example

    ::Parcels.view_paths = [ path('views') ]
  end

  attr_reader :this_example

  def sprockets_env(*args, &block)
    if args.length > 0 || block
      raise "Duplicate creation of sprockets_env? #{args.inspect}" if @sprockets_env
      args = [ this_example_root ] if args.length == 0
      @sprockets_env = new_sprockets_env(*args)
      block.call(@sprockets_env) if block
    else
      @sprockets_env ||= begin
        out = new_sprockets_env(this_example_root)
        out.append_path 'assets'
        out
      end
    end
  end

  it "should aggregate the CSS from a simple widget properly" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels views
        h1 { color: blue; }
      }

      widget 'views/my_widget' do
        css %{
          p { color: red; }
        }
      end
    }

    asset = sprockets_env.find_asset('basic')
    expect(asset).not_to be_nil
    $stderr.puts "BODY: <<#{asset.body}>>"
  end
end
