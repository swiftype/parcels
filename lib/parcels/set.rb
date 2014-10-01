require 'active_support/core_ext/module/delegation'
require 'fileutils'

require 'parcels/dependency_parcel_list'
require 'parcels/fortitude_inline_parcel'
require 'parcels/utils/path_utils'

module Parcels
  class Set
    def initialize(set_definition)
      @set_definition = set_definition
      @sprockets_contexts_added_to = { }

      @parcels = { }
    end

    def add_to_sprockets_context!(context)
      return if sprockets_contexts_added_to[context]
      do_add_to_sprockets_context!(context)
      sprockets_contexts_added_to[context] = true
    end

    def logical_path_for_full_path(full_path)
      File.join(Parcels::SetDefinition::PARCELS_LOGICAL_PATH_PREFIX, ::Parcels::Utils::PathUtils.path_under(full_path, root))
    end

    delegate :widget_roots, :to => :set_definition



    private
    attr_reader :set_definition, :sprockets_contexts_added_to, :parcels

    delegate :parcels_environment, :root, :to => :set_definition

    EXTENSION_TO_PARCEL_CLASS_MAP   = {
      '.rb'.freeze => ::Parcels::FortitudeInlineParcel
    }.freeze

    ALL_EXTENSIONS                    = EXTENSION_TO_PARCEL_CLASS_MAP.keys.dup.freeze

    def do_add_to_sprockets_context!(context)
      return unless File.directory?(root)

      context.depend_on(root)

      Find.find(root) do |path|
        full_path = File.expand_path(path, root)
        next unless File.file?(full_path)

        extension = File.extname(full_path).strip.downcase
        if (klass = EXTENSION_TO_PARCEL_CLASS_MAP[extension])
          parcel = klass.new(self, full_path)
          parcels[full_path] = parcel
        end
      end

      parcel_list = ::Parcels::DependencyParcelList.new
      parcel_list.add_parcels!(parcels.values)
      parcel_list.parcels_in_order.each do |parcel|
        parcel.add_to_sprockets_context!(context)
      end
    end
  end
end
