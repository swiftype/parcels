class Parcels
  module Rails
    class Railtie < ::Rails::Railtie
      # initializer :parcels, :before => :set_autoload_paths do |app|
      #   view_paths.each do |view_path|
      #     app.config.assets.paths << app.config.assets.parcels._sprockets_workaround_directory_for(view_path)
      #   end
      # end

      config.after_initialize do
        app.config.assets.parcels.root = ::Rails.root

        # TODO
        # TODO: Use the real list of Rails view paths from its config, instead of this
        app.config.assets.parcels.view_paths = File.join('app', 'views')
      end
    end
  end
end
