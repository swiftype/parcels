require 'parcels'
require 'helpers/file_structure_helpers'
require 'helpers/content_in_helpers'
require 'helpers/sprockets_helpers'
require 'helpers/per_example_helpers'
require 'helpers/parcels_rails_helpers'
require 'oop_rails_server'

RSpec.configure do |c|
  c.include FileStructureHelpers, :type => :system
  c.include ContentInHelpers, :type => :system
  c.include SprocketsHelpers, :type => :system
  c.include PerExampleHelpers, :type => :system

  c.include ::OopRailsServer::Helpers, :type => :rails
  c.include ParcelsRailsHelpers, :type => :rails

  c.before(:each) do |example|
    set_up_per_example_data!(example) if example.metadata[:type] == :system
  end
end
