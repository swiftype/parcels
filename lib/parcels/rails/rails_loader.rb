# See if we can load Rails -- but don't fail if we can't; we'll just use this to decide whether we should
# load the Rails extensions or not.
begin
  gem 'rails'
rescue Gem::LoadError => le
  # ok
end

begin
  require 'rails'
rescue LoadError => le
  # ok
end

if defined?(::Rails)
  require 'parcels/rails/railtie'

  begin
    require 'sass-rails'
  rescue LoadError => le
    # ok
  end
end
