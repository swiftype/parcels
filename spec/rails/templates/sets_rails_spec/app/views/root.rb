class Views::Root < Views::Widgets::Base
  parcels_sets do |klass, filename|
    if filename =~ /admin/
      :admin
    else
      :normal
    end
  end
end
