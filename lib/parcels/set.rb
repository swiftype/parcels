require 'active_support/core_ext/module/delegation'
require 'fileutils'

require 'parcels/fragments/fortitude_widget_fragment'
require 'parcels/utils/path_utils'

module Parcels
  class Set
    def initialize(set_definition)
      @set_definition = set_definition
      @sprockets_contexts_added_to = { }

      @fragments = { }
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
    attr_reader :set_definition, :sprockets_contexts_added_to, :fragments

    delegate :parcels, :root, :to => :set_definition

    EXTENSION_TO_FRAGMENT_CLASS_MAP   = {
      '.rb'.freeze => ::Parcels::Fragments::FortitudeWidgetFragment
    }.freeze

    ALL_EXTENSIONS                    = EXTENSION_TO_FRAGMENT_CLASS_MAP.keys.dup.freeze

    def do_add_to_sprockets_context!(context)
      return unless File.directory?(root)

      context.depend_on(root)

      Find.find(root) do |path|
        full_path = File.expand_path(path, root)
        next unless File.file?(full_path)

        extension = File.extname(full_path).strip.downcase
        if (klass = EXTENSION_TO_FRAGMENT_CLASS_MAP[extension])
          fragment = klass.new(self, full_path)
          fragments[full_path] = fragment
        end
      end

      fragments.each do |full_path, fragment|
        fragment.add_to_sprockets_context!(context)
      end
    end
  end
end
