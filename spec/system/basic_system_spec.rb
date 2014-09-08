require 'fileutils'

require 'sprockets'
require 'parcels'

module Views
  class SpecWidget < ::Fortitude::Widget
    doctype :html5

    def content
      text "spec_widget #{self.class.name} contents!"
    end
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
      superclass = options[:superclass] || ::Views::SpecWidget
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

    ::Parcels.view_paths = [ File.join(this_example_root, 'views') ]
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
        expected_rules = Array(expected_rules)
        actual_rules_found = nil

        $stderr.puts "remaining_css_array: #{remaining_css_array.inspect}"
        remaining_css_array.each_with_index do |actual_css_line, index|
          $stderr.puts "actual_css_line: #{actual_css_line.inspect}"
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

  def expect_widget_css_in(asset_path, subpath, css_selector_to_rules_map)
    source = asset_source(asset_path)
    $stderr.puts "file_content_in(#{asset_path}):\n#{file_content_in(asset_path).inspect}"
    $stderr.puts "css_content_in(#{asset_path}):\n#{css_content_in(asset_path).inspect}"
    from_line_regexp = %r{^\s*/\*\s*From[\s'"]*#{Regexp.escape(File.join(this_example_root, subpath))}(.rb)?['"\s]*:\s*\d+\s*\*/\s*$}mi
    from_match = source.match(from_line_regexp)
    unless from_match
      raise "Unable to find a 'from' line showing an inclusion of #{subpath.inspect} in asset #{asset_path.inspect}; its contents are:\n#{source}"
    end

    next_from_match = source.match(%r{^\s*/*\s*From[\s'"]*.**/$}i, from_match.end(0))
    ending = if next_from_match then (next_from_match.start(0) - 1) else -1 end
    css_rules = source[from_match.end(0)..ending]

    widget_class = subpath.camelize.constantize

    css_selector_to_rules_map.each do |selector, expected_rules|
      expected_rules = Array(expected_rules)

      expected_rule_start_regexp = /^\s*\.#{Regexp.escape(widget_class._parcels_widget_outer_element_class)}\s+#{Regexp.escape(selector)}\s+\{/m
      rule_start_match = css_rules.match(expected_rule_start_regexp)
      unless rule_start_match
        raise "Found the inclusion of #{subpath.inspect} in asset #{asset_path.inspect}, but were unable to find a rule for #{selector.inspect} in its CSS rules, which are:\n#{css_rules}"
      end
      rule_end_match = css_rules.match(/\}/, rule_start_match.end(0))
      unless rule_end_match
        raise "Can't find the end of the rule for #{selector} in the CSS for #{subpath.inspect} inside #{asset_path.inspect}, which is:\n#{css_rules}"
      end
      all_rules_text = css_rules[(rule_start_match.end(0))..(rule_end_match.begin(0) - 1)]
      all_rules = all_rules_text.strip.split(/\s*\n\s*/mi).map do |rule|
        if rule =~ /^\s*(.*?)\s*;\s*$/i
          $1
        else
          rule
        end
      end

      expected_rules.each do |expected_rule|
        matching_actual_rule_index = all_rules.index { |actual_rule| expected_rule == actual_rule }
        unless matching_actual_rule_index
          raise "Can't find a rule matching the expected rule #{expected_rule.inspect} in the CSS for #{subpath.inspect} inside #{asset_path.inspect}, which is:\n#{css_rules}"
        end

        all_rules.delete_at(matching_actual_rule_index)
      end

      unless all_rules.length == 0
        raise "Extra rules found for #{selector} in the CSS for #{subpath.inspect} inside #{asset_path.inspect}:\n#{all_rules.inspect}"
      end
    end
  end

  it "should aggregate the CSS from a simple widget properly" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { color: red; }
        }
      end
    }

    ::Parcels._ensure_view_paths_are_symlinked!
    ::Parcels.view_paths.each do |view_path|
      sprockets_env.prepend_path(::Parcels._sprockets_workaround_directory_for(view_path))
    end

    asset = sprockets_env.find_asset('basic')
    expect(asset).not_to be_nil

    expect_css_content_in('basic',
      'views/my_widget.rb' => {
        [ ".#{::Views::MyWidget._parcels_widget_outer_element_class}", "p" ] => "color: red"
      })
    # expect_widget_css_in('basic', 'views/my_widget',
    #   :p => 'color: red')

    # expect(asset.source).to match(%r{/*\s*From.*#{File.join(this_example_root, 'views/my_widget.rb')}})
    # expect(asset.source).to match(%r{.#{::Views::MyWidget._parcels_widget_outer_element_class}\s+p\s+\{\s*color:\s*red\s*;\s*\}}mi)
  end
end
