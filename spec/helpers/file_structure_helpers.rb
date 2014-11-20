require 'fortitude'

require 'active_support/concern'

require 'spec/fixtures/file_set'

module Views; end

module FileStructureHelpers
  extend ActiveSupport::Concern

  included do
    after :each do
      unload_all_classes!
    end
  end

  def this_example_root
    per_example_data[:this_example_root] ||= clean_directory(this_spec_root, this_example_name)
  end

  def files(&block)
    per_example_data[:file_set_fixture] ||= ::Spec::Fixtures::FileSet.new(this_example_root)
    per_example_data[:file_set_fixture].instance_eval(&block)
    per_example_data[:file_set_fixture].create!
  end

  private
  def unload_all_classes!
    fd = per_example_data[:file_set_fixture]
    fd.unload_all_classes! if fd
  end

  def this_example_name
    per_example_data[:this_example_name] ||= this_example.metadata[:full_description].strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
  end

  def this_spec_root
    per_example_data[:this_spec_root] ||= extant_directory(tempdir_root, this_spec_name)
  end

  def this_spec_name
    per_example_data[:this_spec_name] ||= begin
      name = self.class.name
      name = $1 if name =~ /::([^:]+)$/i
      name.strip.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
    end
  end

  def gem_root
    per_example_data[:gem_root] ||= extant_directory(File.dirname(File.dirname(File.dirname(__FILE__))))
  end

  def tempdir_root
    per_example_data[:tempdir_root] ||= extant_directory(gem_root, 'tmp', 'spec')
  end

  def extant_directory(*path_components)
    out = path(*path_components)
    FileUtils.mkdir_p(out)
    out
  end

  def clean_directory(*path_components)
    p = path(*path_components)
    FileUtils.rm_rf(p)
    FileUtils.mkdir_p(p)
    p
  end

  def path(*path_components)
    File.expand_path(File.join(*path_components))
  end
end
