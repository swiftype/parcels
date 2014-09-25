require 'nokogiri'

module ContentInHelpers
  def asset_source(asset_path, options = { })
    env = options[:sprockets_env] || sprockets_env
    asset = env.find_asset(asset_path)
    unless asset
      raise "We expected to have an asset called #{asset_path.inspect}, but got none"
    end

    asset.source
  end

  FROM_LINE_REGEXP = %r{^\s*\/\*\s*From[\s'"]*([^'"]+?)\s*[\s'"]*:\s*(\d+)\s*\*/\s*$}i
  BREAK_LINE_REGEXP = %r{^\s*//\s*===\s*BREAK\s*===\s*$}i

  def file_content_in(asset_path)
    source = asset_source(asset_path)
    file_to_content_map = { }

    remaining = source
    last_source_file = :head
    last_source_line = nil
    loop do
      remaining = remaining.strip
      break if remaining.length == 0

      from_line_match = FROM_LINE_REGEXP.match(remaining)

      if (! from_line_match)
        break_match = BREAK_LINE_REGEXP.match(remaining)
        end_pos = if break_match then (break_match.begin(0) - 1) else -1 end

        file_to_content_map[last_source_file] = {
          :line => last_source_line,
          :content => remaining[0..end_pos].strip
        }

        if break_match
          file_to_content_map[:tail] = {
            :line => nil,
            :content => remaining[(break_match.end(0))..-1].strip
          }
        end

        break
      end

      if (beginning = from_line_match.begin(0)) > 0
        file_to_content_map[last_source_file] = {
          :line => last_source_line,
          :content => remaining[0..(beginning - 1)]
        }
      end

      last_source_file = from_line_match.captures[0]
      if last_source_file[0..(this_example_root.length - 1)] == this_example_root
        last_source_file = last_source_file[(this_example_root.length + 1)..-1]
      end

      last_source_line = from_line_match.captures[1]
      remaining = remaining[from_line_match.end(0)..-1]
    end

    file_to_content_map
  end

  def css_content_in(asset_path)
    out = { }

    file_content_in(asset_path).each do |filename, file_data|
      this_css_content = [ ]

      remaining_content = file_data[:content]
      loop do
        break unless remaining_content
        remaining_content = remaining_content.strip
        break if remaining_content.length == 0
        if remaining_content =~ %r{\A(/\*\s*.*?\s*\*\/)(.*)\Z}mi
          this_css_content << $1
          remaining_content = $2
        elsif remaining_content =~ %r{\A//([^\n])+(.*)\Z}mi
          this_css_content << $1
          remaining_content = $2
        elsif remaining_content =~ /\A((?:\S+\s*)+)\s*\{\s*([^\}]+?)\s*\}\s*(.*)\Z/mi
          selector = $1
          rules = $2
          remaining_content = $3

          this_css_content << ([ selector.split(/\s+/) ] + rules.split(/\s*\;\s*/mi))
        else
          raise "Don't know how to parse remaining content of #{filename}, which is:\n#{remaining_content}"
        end

        out[filename] = file_data.merge(:css => this_css_content)
      end
    end

    out
  end

  def subpath_to_widget_class(subpath)
    full_path = File.join(this_example_root, subpath)
    full_path += ".rb" unless full_path =~ /\.rb\s*$/i
    Fortitude::Widget.widget_class_from_file(full_path, :root_dirs => this_example_root)
  end

  def widget_outer_element_class_from_subpath(subpath)
    "#{subpath_to_widget_class(subpath)._parcels_widget_outer_element_class}"
  end

  def expect_css_content_in(asset_path, expected_content)
    actual_content = css_content_in(asset_path)
    remaining_content = actual_content.dup

    expected_content.each do |expected_path, expected_css_selector_array_to_rules_map|
      actual_file_data = remaining_content.delete(expected_path)
      unless actual_file_data
        raise "We expected to find CSS content in #{asset_path.inspect} for #{expected_path.inspect}, but found none! We have content for: #{actual_content.keys.inspect}"
      end

      actual_css_array = actual_file_data[:css]
      unless actual_css_array
        raise "We expected to find CSS content in #{asset_path.inspect} for #{expected_path.inspect}, but, while that file exists, we didn't find any CSS content in it! Instead, we got: #{actual_file_data.inspect}"
      end

      remaining_css_array = actual_css_array.dup
      expected_css_selector_array_to_rules_map.each do |expected_css_selector_array, expected_rules|
        expected_css_selector_array = Array(expected_css_selector_array)

        if expected_css_selector_array[0] == :_widget_scope
          expected_css_selector_array = [ ".#{widget_outer_element_class_from_subpath(expected_path)}" ] + expected_css_selector_array[1..-1]
        end
        expected_css_selector_array = expected_css_selector_array.map(&:to_s)

        expected_rules = Array(expected_rules)
        actual_rules_found = nil

        remaining_css_array.each_with_index do |actual_css_line, index|
          if actual_css_line.kind_of?(Array)
            actual_selector_array = actual_css_line[0]
            actual_rules = actual_css_line[1..-1]

            if actual_selector_array == expected_css_selector_array
              actual_rules_found = actual_rules
              remaining_css_array.delete_at(index)
              break
            end
          end
        end

        unless actual_rules_found
          raise "In #{expected_path.inspect} (inside #{asset_path.inspect}), we expected to find CSS rules for #{expected_css_selector_array.inspect}, but didn't; instead, we have:\n#{actual_css_array.inspect}"
        end

        unless actual_rules_found == expected_rules
          raise "In #{expected_path.inspect} (inside #{asset_path.inspect}), we have the wrong CSS Rules for #{expected_css_selector_array.inspect}; we expected: #{expected_rules.inspect}, but actually had: #{actual_rules_found.inspect}"
        end
      end

      if remaining_css_array.length > 0
        raise "In #{expected_path.inspect} (inside #{asset_path.inspect}), we have extra CSS that we didn't expect: #{remaining_css_array.inspect}"
      end
    end

    if remaining_content.size > 0
      raise "For #{asset_path}, we have extra CSS content that we didn't expect: #{remaining_content.inspect}"
    end
  end

  def widget_scoped(*css_selector_array)
    css_selector_array = css_selector_array.flatten.map(&:to_s)
    [ :_widget_scope ] + css_selector_array
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
