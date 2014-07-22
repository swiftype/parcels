require 'find'

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*args)
    ::Parcels.view_paths.each do |view_path|
      next unless File.directory?(view_path)

      context.depend_on(view_path)
      Find.find(view_path) do |filename|
        # TODO: Add support for sidecar .css/.js files, etc.
        next unless File.extname(filename).strip.downcase == ".rb"
        context.require_asset(filename)
      end
    end
  end
end
