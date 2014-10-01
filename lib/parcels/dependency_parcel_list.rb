require 'tsort'

module Parcels
  class DependencyParcelList
    def initialize
      @tag_to_child_tag_map = { }
      @parcel_to_tag_map = { }
      @tag_to_parcel_map = { }

      @loose_parcels = [ ]
    end

    def tsort_each_node(&block)
      parcel_to_tag_map.keys.each(&block)
    end

    def tsort_each_child(parcel, &block)
      tag = parcel_to_tag_map[parcel]
      child_tags = tag_to_child_tag_map[tag] || [ ]
      child_parcels = child_tags.map { |t| tag_to_parcel_map[t] }.compact

      child_parcels.each(&block)
    end

    def add_parcels!(parcels)
      parcels.each do |parcel|
        if parcel.tag
          parcel_to_tag_map[parcel] = parcel.tag
          tag_to_parcel_map[parcel.tag] = parcel

          parcel.tags_that_must_come_before.each do |tag_that_must_come_before|
            tag_to_child_tag_map[tag_that_must_come_before] ||= [ ]
            tag_to_child_tag_map[tag_that_must_come_before] << parcel.tag
          end
        else
          loose_parcels << parcel
        end
      end
    end

    def parcels_in_order
      tsort.reverse # tsort puts children before parents; we want the exact opposite
    end

    include TSort

    private
    attr_reader :tag_to_child_tag_map, :parcel_to_tag_map, :tag_to_parcel_map, :loose_parcels
  end
end
