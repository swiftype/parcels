require 'nokogiri'

module ContentInHelpers
  def subpath_to_widget_class(subpath)
    subpath = $1 if subpath =~ %r{^(.*?)\.[^/]+$}i
    full_path = File.join(this_example_root, subpath)
    full_path += ".rb" unless full_path =~ /\.rb\s*$/i
    Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => this_example_root)
  end

  def rendered_widget_content(widget_subpath, args = { }, options = { })
    widget_class = subpath_to_widget_class(widget_subpath)
    html = widget_class.new(args).to_html
    out = Nokogiri::HTML(html)
    out = out.xpath('/html/body') if options.fetch(:extract_body_contents, true)
    out
  end

  def classes_from(node, xpath)
    elements = node.xpath(xpath)

    if elements.length == 0
      raise "No elements matched #{xpath.inspect} from here: #{node}"
    elsif elements.length == 1
      element = elements[0]
      class_string = element['class']
      if class_string
        class_string.split(/\s+/)
      else
        [ ]
      end
    else
      raise "Multiple elements matched #{xpath.inspect} from here: #{node}; they are: #{elements.inspect}"
    end
  end
end
