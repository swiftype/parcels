require 'spec/fixtures/widget_base'
require 'spec/fixtures/widget_file'

module Spec
  module Fixtures
    class FileSet
      attr_reader :root_dir

      def initialize(root_dir)
        @root_dir = root_dir
        @files = { }
        @widgets = { }
      end

      def file(subpath, contents = nil)
        contents = $2 if contents =~ /\A(\s*\n)*(.*?)(\s\n)*\Z/mi
        files[subpath] = contents
      end

      def widget(subpath, options = { }, &block)
        class_name = options[:class_name]
        class_name ||= begin
          out = subpath
          out = $1 if out =~ /^(.*)(\.[A-Z0-9_]+)+$/i
          out = out.camelize
          out
        end
        superclass = options[:superclass] || ::Spec::Fixtures::WidgetBase
        superclass = superclass.name if superclass.kind_of?(Class)
        subpath += ".rb" unless subpath =~ /\.rb$/i

        widget_definition = ::Spec::Fixtures::WidgetFile.new(class_name, superclass, root_dir)
        widget_definition.instance_eval(&block) if block

        @widgets[subpath] = widget_definition
      end

      def create!
        files.each do |subpath, contents|
          full_path = File.join(root_dir, subpath)
          FileUtils.mkdir_p(File.dirname(full_path))
          File.open(full_path, 'w') { |f| f << contents }
        end

        widgets.each do |subpath, definition|
          full_path = File.join(root_dir, subpath)
          FileUtils.mkdir_p(File.dirname(full_path))
          File.open(full_path, 'w') { |f| f << definition.source_text }
        end
      end

      def unload_all_classes!
        subpaths = files.keys | widgets.keys

        subpaths.each do |subpath|
          next unless subpath =~ /\.rb$/i
          full_path = File.join(root_dir, subpath)
          widget_class = ::Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => root_dir) rescue nil

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
      attr_reader :files, :widgets
    end
  end
end
