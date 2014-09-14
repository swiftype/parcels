module Parcels
  module Utils
    module PathUtils
      class << self
        def path_under(path, under_what)
          path = path.to_s.strip
          under_what = under_what.to_s.strip

          if (path.length - under_what.length) > 1 && path[0..(under_what.length - 1)] == under_what &&
            path[under_what.length] == File::SEPARATOR

            path[(under_what.length + 1)..-1]
          else
            raise Errno::ENOENT, %{Path #{path.inspect} is not underneath directory #{under_what.inspect}.}
          end
        end
      end
    end
  end
end
