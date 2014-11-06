require "parcels"

module Parcels
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        parcels = ::Rails.application.assets.parcels

        parcels.root = ::Rails.root
        parcels.widget_roots = ::Rails.application.config.autoload_paths


        sets_defined = { }

        ::ApplicationController.view_paths.map(&:to_s).each do |view_path|
          view_path = File.expand_path(view_path)

          set_name = File.basename(view_path).to_sym
          set_name = :all if view_path == File.expand_path(File.join(::Rails.root, 'app', 'views'))

          if sets_defined[set_name]
            $stderr.puts %{WARNING: Parcels could not define a Parcels set named #{set_name.inspect} for the Rails view path:
  #{view_path}
...because there is already a set named #{set_name.inspect}, which we defined for the Rails view path:
  #{sets_defined[set_name]}.}
          else
            parcels.define_set!(set_name, view_path)
            sets_defined[set_name] = view_path
            $stderr.puts "Defining set: #{set_name.inspect} for #{view_path.inspect}"
          end
        end
      end
    end
  end
end
