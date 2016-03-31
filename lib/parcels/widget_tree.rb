require 'active_support/core_ext/module/delegation'

require 'parcels/fortitude_inline_parcel'
require 'parcels/fortitude_alongside_parcel'
require 'parcels/dependency_parcel_list'

require 'pathname'

require 'find'

module Parcels
  class WidgetTree
    attr_reader :root, :parcels_environment

    def initialize(parcels_environment, root)
      @parcels_environment = parcels_environment
      @root = File.expand_path(root, parcels_environment.root)

      @sprockets_environments_added_to = { }
    end

    def widget_naming_root_dirs
      @widget_naming_root_dirs ||= [ root, File.dirname(root) ]
    end

    def add_workaround_directory_to_sprockets!(sprockets_environment)
      return if (! root_exists?)

      @sprockets_environments_added_to[sprockets_environment] ||= begin
        sprockets_environment.prepend_path(workaround_directory)
        true
      end
    end

    def subpath_to(full_path)
      ::Parcels::Utils::PathUtils.path_under(full_path, root)
    end

    def remove_workaround_directory_from(full_path)
      if (path_under_workaround = ::Parcels::Utils::PathUtils.maybe_path_under(full_path, workaround_directory))
        if (separator_index = path_under_workaround.index(File::SEPARATOR))
          if (separator_index > 0 && separator_index < (path_under_workaround.length - 1))
            link_name = path_under_workaround[0..(separator_index - 1)]
            after_link = path_under_workaround[(separator_index + 1)..-1]

            if File.symlink?(File.join(workaround_directory, link_name))
              link_value = File.readlink(File.join(workaround_directory, link_name))
              resolved_link = File.expand_path(File.join(workaround_directory, link_value))
              final_path = File.join(resolved_link, after_link)
              return final_path
            end
          end
        end
      end

      nil
    end

    def add_all_widgets_to_sprockets_context!(sprockets_context, set_names)
      return unless root_exists?
      sprockets_context.depend_on(root)

      all_parcels = [ ]

      Find.find(root) do |path|
        full_path = File.expand_path(path, root)
        stat = File.stat(full_path)

        sprockets_context.depend_on(path) if stat.directory?
        next unless stat.file?

        extension = File.extname(full_path).strip.downcase
        if (klass = EXTENSION_TO_PARCEL_CLASS_MAP[extension])
          parcel = klass.new(self, full_path)
          if parcel.usable? && parcel.included_in_any_set?(set_names)
            if all_parcels.length == 0
              ensure_workaround_directory_is_set_up!
            end

            all_parcels << parcel
          end
        end
      end

      parcel_list = ::Parcels::DependencyParcelList.new
      parcel_list.add_parcels!(all_parcels)
      parcel_list.parcels_in_order.each do |parcel|
        parcel.add_to_sprockets_context!(sprockets_context)
      end
    end

    # not ideal since this same traversal happens in add_all_widgets_to_sprockets_context
    # fortunately we have an early return if we run into a usable parcel
    def ensure_workaround_directory_is_set_up_during_init!
      Find.find(root) do |path|
        full_path = File.expand_path(path, root)
        stat = File.stat(full_path)
        next unless stat.file?

        extension = File.extname(full_path).strip.downcase
        if (klass = EXTENSION_TO_PARCEL_CLASS_MAP[extension])
          parcel = klass.new(self, full_path)
          if parcel.usable? # note the lack of set_names here
            ensure_workaround_directory_is_set_up!
            return
          end
        end
      end
    end

    private
    EXTENSION_TO_PARCEL_CLASS_MAP   = {
      '.rb'.freeze => ::Parcels::FortitudeInlineParcel,
      '.pcss'.freeze => ::Parcels::FortitudeAlongsideParcel
    }.freeze

    ALL_EXTENSIONS                    = EXTENSION_TO_PARCEL_CLASS_MAP.keys.dup.freeze

    PARCELS_LOGICAL_PATH_PREFIXES     = EXTENSION_TO_PARCEL_CLASS_MAP.values.map { |k| k.logical_path_prefix }

    def root_exists?
      File.exist?(root)
    end

    def workaround_directory
      @workaround_directory ||= parcels_environment.workaround_directory_root_for_widget_tree(self)
    end

    def ensure_workaround_directory_is_set_up!
      @workaround_directory_exists ||= begin
        ensure_workaround_directory_exists!
        ensure_nothing_else_is_in_workaround_directory!
        ensure_symlinks_point_to_the_right_place!

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
      extra = entries - PARCELS_LOGICAL_PATH_PREFIXES

      if extra.length > 0
        raise Errno::EEXIST, %{Parcels uses the directory '#{workaround_directory}' internally
(to allow us to safely add assets to Sprockets without treading on the global asset namespace);
it should either be empty, or contain at most symlinks named any of
#{PARCELS_LOGICAL_PATH_PREFIXES.map { |p| "'#{p}'" }.join(", ")}.
(Parcels will create those symlinks automatically; you should not manage them yourself.)

However, this directory currently contains other file(s) that we weren't expecting:

#{extra.join("\n")}}
      end
    end

    SYMLINK_TARGET = "..".freeze

    def ensure_symlinks_point_to_the_right_place!
      PARCELS_LOGICAL_PATH_PREFIXES.each do |prefix|
        symlink = File.join(workaround_directory, prefix)

        if File.exist?(symlink)
          if File.symlink?(symlink)
            contents = File.readlink(symlink)

            if contents == symlink_target
              # ok, great
            else
              File.delete(symlink)
              create_symlink!(prefix)
            end
          else
            raise Errno::EEXIST, %{Parcels uses the directory '#{workaround_directory}' internally
(to allow us to safely add assets to Sprockets without treading on the global asset namespace);
it should either be empty, or contain at most symlinks named any of
#{PARCELS_LOGICAL_PATH_PREFIXES.map { |p| "'#{p}'" }.join(", ")}.

This directory has a file called '#{prefix}' that isn't a symlink.
Out of respect for your data, we're going to raise this fatal error. Please check what's going on,
and try again.}
          end
        else
          create_symlink!(prefix)
        end
      end
    end

    def create_symlink!(prefix)
      Dir.chdir(workaround_directory) do
        FileUtils.ln_s(symlink_target, prefix)
      end
    end

    def symlink_target
      workaround_dir_path = Pathname.new(workaround_directory).realpath
      root_path = Pathname.new(root).realpath
      root_path.relative_path_from(workaround_dir_path).to_s
    end
  end
end
