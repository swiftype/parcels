require 'parcels'
require 'helpers/file_structure_helpers'
require 'helpers/content_in_helpers'
require 'helpers/sprockets_helpers'

RSpec.configure do |c|
  c.include FileStructureHelpers, :type => :system
  c.include ContentInHelpers, :type => :system
  c.include SprocketsHelpers, :type => :system

  c.before(:each) do |example|
    @this_example = example
  end
end
