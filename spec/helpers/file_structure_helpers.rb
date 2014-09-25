require 'fortitude'

require 'active_support/concern'

module Views; end

module FileStructureHelpers
  extend ActiveSupport::Concern

  included do
    after :each do
      unload_all_classes!
    end
  end

  class SpecWidget < ::Fortitude::Widget
    doctype :html5

    enable_parcels!

    def content
      div do
        p do
          text "spec_widget #{self.class.name} contents!"
        end
      end
    end
  end

  class WidgetDefinition
    def initialize(class_name, superclass)
      @class_name = class_name
      @superclass = superclass
      @css = [ ]
    end

    def css(css_text)
      @css << css_text
    end

    def content(content_text)
      @content_text = content_text
    end

    def source_text
      text = [ "class #{class_name} < ::#{superclass}" ]

      @css.each do |css_text|
        text += [ "  css <<-EOS", css_text, "EOS" ]
      end

      if @content_text
        text += [ "  def content", @content_text, "  end" ]
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
      superclass = options[:superclass] || SpecWidget
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

    def unload_all_classes!
      subpaths = files.keys | widgets.keys

      subpaths.each do |subpath|
        next unless subpath =~ /\.rb$/i
        full_path = File.join(spec.this_example_root, subpath)
        widget_class = ::Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => spec.this_example_root)

        if widget_class
          parent = constant_name = nil

          if widget_class.name =~ /^(.*)::([^:]+)$/i
            parent = $1.constantize
            constant_name = $2.to_sym
          else
            parent = ::Object
            constant_name = widget_class.name.to_sym
          end

          parent.send(:remove_const, constant_name)
        end
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
    per_example_data[:gem_root] ||= extant_directory(File.dirname(File.dirname(__FILE__)))
  end

  def tempdir_root
    per_example_data[:tempdir_root] ||= extant_directory(gem_root, 'tmp')
  end

  def this_spec_name
    per_example_data[:this_spec_name] ||= begin
      name = self.class.name
      name = $1 if name =~ /::([^:]+)$/i
      name.strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
    end
  end

  def this_spec_root
    per_example_data[:this_spec_root] ||= extant_directory(tempdir_root, this_spec_name)
  end

  def this_example_name
    per_example_data[:this_example_name] ||= this_example.metadata[:full_description].strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
  end

  def this_example_root
    per_example_data[:this_example_root] ||= clean_directory(this_spec_root, this_example_name)
  end

  def files(&block)
    per_example_data[:file_definition] ||= SpecFileSet.new(self)
    per_example_data[:file_definition].instance_eval(&block)
    per_example_data[:file_definition].create!
  end

  def unload_all_classes!
    fd = per_example_data[:file_definition]
    fd.unload_all_classes! if fd
  end
end
