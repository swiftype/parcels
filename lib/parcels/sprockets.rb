require 'active_support'
require 'active_support/core_ext/string'

require 'find'
require 'tsort'

require "parcels/index"

class FortitudeWidgetSet
  include TSort

  def tsort_each_node(&block)
    widget_class_to_file_map.keys.each(&block)
  end

  def tsort_each_child(widget_class, &block)
    (widget_class_to_subclasses_map[widget_class] || [ ]).each(&block)
  end

  def initialize(parcels)
    @parcels = parcels
    @widget_class_to_file_map = { }
    @widget_class_to_subclasses_map = { }
  end

  def add_widget_from_file!(filename)
    widget_class = ::Fortitude::Widget.widget_class_from_file(filename, :root_dirs => parcels.view_paths)

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
    tsort.reverse.each(&block)
  end

  def file_for_widget_class(widget_class)
    widget_class_to_file_map[widget_class]
  end

  private
  attr_reader :widget_class_to_file_map, :widget_class_to_subclasses_map, :parcels
end

::Sprockets::Environment.class_eval do
  def parcels
    @parcels ||= ::Parcels::Environment.new(self)
  end

  def index_with_parcels
    parcels.create_and_add_all_workaround_directories!
    index_without_parcels
  end

  alias_method_chain :index, :parcels
end

::Sprockets::Index.class_eval do
  def parcels
    @parcels ||= ::Parcels::Index.new(@environment.parcels)
  end
end

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*args)
    args = [ ::Parcels::Environment::PARCELS_DEFAULT_SET_NAME ] if args.empty?
    parcels = context.environment.parcels

    args.each do |set_name|
      set = parcels.set(set_name)
      set.add_to_sprockets_context!(context)
    end
  end
end
