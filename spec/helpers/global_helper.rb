require 'parcels'
require 'helpers/file_structure_helpers'
require 'helpers/content_in_helpers'
require 'helpers/sprockets_helpers'
require 'helpers/per_example_helpers'

RSpec.configure do |c|
  c.include FileStructureHelpers, :type => :system
  c.include ContentInHelpers, :type => :system
  c.include SprocketsHelpers, :type => :system
  c.include PerExampleHelpers, :type => :system

  c.before(:each) do |example|
    set_up_per_example_data!(example)
  end
end
