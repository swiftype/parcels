require 'active_support/core_ext/module/delegation'

module Parcels
  class SetDefinition
    attr_reader :name, :root

    def initialize(parcels, name, root = nil, &block)
      @name = name
      @parcels = parcels
      self.root = root if root

      instance_eval(&block) if block
    end

    def root=(new_root)
      @root = File.expand_path(new_root, parcels.root)
    end

    def add_workaround_directory_to_sprockets!(sprockets_environment)
      return if (! root_exists?)

      ensure_workaround_directory_is_set_up!
      sprockets_environment.prepend_path(workaround_directory)
    end

    delegate :widget_roots, :to => :parcels

    private
    attr_reader :parcels

    PARCELS_WORKAROUND_DIRECTORY_NAME = ".parcels_sprockets_workaround".freeze
    PARCELS_LOGICAL_PATH_PREFIX       = "_parcels".freeze

    def root_exists?
      File.exist?(root)
    end

    def workaround_directory
      @workaround_directory ||= File.join(root, PARCELS_WORKAROUND_DIRECTORY_NAME)
    end

    def ensure_workaround_directory_is_set_up!
      @workaround_directory_exists ||= begin
        ensure_workaround_directory_exists!
        ensure_nothing_else_is_in_workaround_directory!
        ensure_symlink_points_to_the_right_place!

        true
      end
    end

    def ensure_workaround_directory_exists!
      unless File.directory?(workaround_directory)
        if File.exist?(workaround_directory)
          raise Errno::EEXIST, %{Parcels uses the directory '#{workaround_directory}' internally
  (to allow us to safely add assets to Sprockets without treading on the global asset namespace);
  however, there is already something at that path that is not a directory.}
        end

        FileUtils.mkdir_p(workaround_directory)
      end
    end

    def ensure_nothing_else_is_in_workaround_directory!
      entries = Dir.entries(workaround_directory).reject { |e| e =~ /^\./ }
      extra = entries - [ PARCELS_LOGICAL_PATH_PREFIX ]

      if extra.length > 0
        raise Errno::EEXIST, %{Parcels uses the directory '#{workaround_directory}' internally
(to allow us to safely add assets to Sprockets without treading on the global asset namespace);
it should either be empty, or contain a single symlink named '#{PARCELS_LOGICAL_PATH_PREFIX}'.
(Parcels will create that symlink automatically; you should not manage it yourself.)

However, this directory currently contains other file(s) that we weren't expecting:

#{extra.join("\n")}}
      end
    end

    SYMLINK_TARGET = "..".freeze

    def ensure_symlink_points_to_the_right_place!
      symlink = File.join(workaround_directory, PARCELS_LOGICAL_PATH_PREFIX)

      if File.exist?(symlink)
        if File.symlink?(symlink)
          contents = File.readlink(symlink)

          if contents == SYMLINK_TARGET
            # ok, great
          else
            File.delete(symlink)
            create_symlink!
          end
        else
          raise Errno::EEXIST, %{Parcels uses the directory '#{workaround_directory}' internally
(to allow us to safely add assets to Sprockets without treading on the global asset namespace);
it should either be empty, or contain a single symlink named '#{PARCELS_LOGICAL_PATH_PREFIX}'.

This directory has a file called '#{PARCELS_LOGICAL_PATH_PREFIX}' that isn't a symlink.
Out of respect for your data, we're going to raise this fatal error. Please check what's going on,
and try again.}
        end
      else
        create_symlink!
      end
    end

    def create_symlink!
      Dir.chdir(workaround_directory) do
        FileUtils.ln_s(SYMLINK_TARGET, PARCELS_LOGICAL_PATH_PREFIX)
      end
    end
  end
end
