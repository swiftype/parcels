require 'active_support'
require 'active_support/core_ext/string'

require 'find'
require 'tsort'

class FortitudeWidgetSet
  include TSort

  def tsort_each_node(&block)
    widget_class_to_file_map.keys.each(&block)
  end

  def tsort_each_child(widget_class, &block)
    (widget_class_to_subclasses_map[widget_class] || [ ]).each(&block)
  end

  def initialize
    @widget_class_to_file_map = { }
    @widget_class_to_subclasses_map = { }
  end

  def add_widget_from_file!(filename)
    widget_class = ::Fortitude::Widget.widget_class_from_file(filename, :root_dirs => ::Parcels.view_paths)

    widget_class_to_file_map[widget_class] = filename

    klass = widget_class
    while true
      the_superclass = klass.superclass
      widget_class_to_subclasses_map[the_superclass] ||= [ ]
      widget_class_to_subclasses_map[the_superclass] |= [ klass ]
      break if the_superclass == ::Fortitude::Widget

      klass = the_superclass
    end
  end

  def each_widget_class(&block)
    all_widget_classes = widget_class_to_file_map.keys
    all_widget_classes = tsort.reverse
    all_widget_classes.each(&block)
  end

  def file_for_widget_class(widget_class)
    widget_class_to_file_map[widget_class]
  end

  private
  attr_reader :widget_class_to_file_map, :widget_class_to_subclasses_map
end

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*args)
    ::Parcels.view_paths.each do |view_path|
      next unless File.directory?(view_path)

      context.depend_on(view_path)

      widget_set = FortitudeWidgetSet.new

      Find.find(view_path) do |filename|
        # TODO: Add support for sidecar .css/.js files, etc.
        next unless File.file?(filename)
        next unless File.extname(filename).strip.downcase == ".rb"

        widget_set.add_widget_from_file!(filename)
      end

      widget_set.each_widget_class do |widget_class|
        filename = widget_set.file_for_widget_class(widget_class)

        subpath = if filename.start_with?(view_path)
          filename[(view_path.length + 1)..-1]
        else
          raise "#{filename.inspect} doesn't start with #{view_path.inspect}?!?"
        end
        logical_path = "#{::Parcels::LOGICAL_PATH_PREFIX}/#{subpath}"

        if widget_class.respond_to?(:_parcels_widget_class_css) && (!(css = widget_class._parcels_widget_class_css).blank?)
          context.require_asset(logical_path)
        else
          context.depend_on_asset(logical_path)
        end
      end



    end
  end
end
