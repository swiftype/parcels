require 'nokogiri'

module ContentInHelpers
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
