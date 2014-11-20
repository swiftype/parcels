module Spec
  module Fixtures
    class WidgetBase < ::Fortitude::Widget
      doctype :html5

      enable_parcels!

      def content
        p "spec_widget #{self.class.name} contents!"
      end
    end
  end
end
