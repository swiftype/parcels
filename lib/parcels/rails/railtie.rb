module Parcels
  module Rails
    class Railtie < ::Rails::Railtie
      def view_paths
        # TODO -- figure out how to grab the array of view paths correctly from Rails...
        [ File.join(::Rails.root, 'app', 'views') ]
      end

      initializer :parcels, :before => :set_autoload_paths do |app|
        view_paths.each do |view_path|
          app.config.assets.paths << ::Parcels._sprockets_workaround_directory_for(view_path)
        end
      end

      config.after_initialize do
        ::Parcels.view_paths += view_paths
        ::Parcels._ensure_view_paths_are_symlinked!
      end
    end
  end
end
