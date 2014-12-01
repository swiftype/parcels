require 'active_support'
require 'active_support/core_ext/string'

require 'find'
require 'tsort'

require "parcels/index"

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
    parcels_environment = context.environment.parcels

    args.each do |set_name|
      set = parcels_environment.set(set_name)
      set.add_to_sprockets_context!(context, parcels_environment)
    end
  end
end

::Sprockets::AssetAttributes.class_eval do
  def format_extension_with_parcels
    out = format_extension_without_parcels
    out = nil if out && out =~ /^\.html$/i
    out
  end

  alias_method_chain :format_extension, :parcels
end
