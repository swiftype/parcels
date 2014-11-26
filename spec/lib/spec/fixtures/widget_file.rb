module Spec
  module Fixtures
    class WidgetFile
      def initialize(class_name, superclass, root_dir)
        @class_name = class_name
        @superclass = superclass
        @root_dir = root_dir
        @css = [ ]
        @requires = [ ]
        @class_text = [ ]
      end

      def css(css_text, options = { })
        @css << {
          :text => css_text,
          :options => options[:options]
        }
      end

      def content(content_text)
        @content_text = content_text
      end

      def class_text(text)
        @class_text << text
      end

      def requires(*the_requires)
        the_requires = Array(the_requires).flatten.uniq
        @requires |= the_requires
      end

      def source_text
        text = [ ]

        @requires.each do |the_require|
          text << "require '#{File.join(@root_dir, the_require)}'"
        end

        text << "class #{class_name} < ::#{superclass}"

        text += @class_text

        @css.each do |data|
          css_text = data[:text]
          options = data[:options]

          if options
            text << "  css <<-EOS, #{options.inspect}"
          else
            text << "  css <<-EOS"
          end

          text << css_text
          text << "EOS"
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
  end
end