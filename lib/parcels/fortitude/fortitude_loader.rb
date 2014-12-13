# See if we can load Fortitude -- but don't fail if we can't; we'll just use this to decide whether we should
# load the Fortitude extensions or not.
begin
  gem 'fortitude'
rescue Gem::LoadError => le
  # ok
end

begin
  require 'fortitude'
rescue LoadError => le
  # ok
end

if defined?(::Fortitude)
  require 'parcels/fortitude/assets'
  require 'parcels/fortitude/enabling'
  require 'parcels/fortitude/widget_engine'
  require 'parcels/fortitude/alongside_engine'

  ::Fortitude::Widget.class_eval do
    include ::Parcels::Fortitude::Assets
    include ::Parcels::Fortitude::Enabling
  end

  ::Parcels.fortitude_available!
end
