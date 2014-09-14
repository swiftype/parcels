module Parcels
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        parcels = app.config.assets.parcels

        parcels.root = ::Rails.root
        parcels.widget_roots = _get_autoload_paths

        parcels.define_set!(:all, _get_all_view_paths)
      end
    end
  end
end
