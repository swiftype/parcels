require "sprockets"

module Parcels
  def self.fortitude_available?
    @fortitude_available || false
  end

  def self.fortitude_available!
    @fortitude_available = true
  end

  def self.is_fortitude_logical_path?(logical_path)
    ::Parcels::FortitudeParcel.is_fortitude_logical_path?(logical_path)
  end
end

require "parcels/version"
require "parcels/rails/rails_loader"
require "parcels/fortitude/fortitude_loader"
require "parcels/sprockets"
require "parcels/environment"
