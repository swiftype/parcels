$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'parcels'
require 'helpers/file_structure_helpers'
require 'helpers/content_in_helpers'
require 'helpers/sprockets_helpers'
require 'helpers/per_example_helpers'
require 'helpers/parcels_rails_helpers'
require 'oop_rails_server'

RSpec.configure do |c|
  c.include ContentInHelpers
  c.include PerExampleHelpers
  c.include FileStructureHelpers

  c.include SprocketsHelpers, :type => :system

  c.include ::OopRailsServer::Helpers, :type => :rails
  c.include ParcelsRailsHelpers, :type => :rails

  c.before(:each) do |example|
    set_up_per_example_data!(example)
  end
end
