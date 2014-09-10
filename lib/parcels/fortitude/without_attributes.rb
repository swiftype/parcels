require 'active_support'
require 'active_support/concern'

require 'parcels/fortitude/attributes'

class Parcels
  module Fortitude
    module WithoutAttributes
      extend ActiveSupport::Concern

      module ClassMethods
        def _parcels_attributes_support_included?
          false
        end

        def _parcels_ensure_attributes_support_included!
          include ::Parcels::Fortitude::Attributes
          unless _parcels_attributes_support_included?
            raise "We included ::Parcels::Fortitude::Attributes into #{self}, yet still don't have attributes support?!?"
          end
        end
      end
    end
  end
end
