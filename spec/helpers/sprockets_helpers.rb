module SprocketsHelpers
  def new_sprockets_env(*args)
    ::Sprockets::Environment.new(*args)
  end

  def sprockets_env(*args, &block)
    out = if args.length > 0 || block
      raise "Duplicate creation of sprockets_env? #{args.inspect}" if @sprockets_env
      args = [ this_example_root ] if args.length == 0
      per_example_data[:sprockets_env] = new_sprockets_env(*args)
      block.call(per_example_data[:sprockets_env]) if block
    else
      per_example_data[:sprockets_env] ||= begin
        out = new_sprockets_env(this_example_root)
        out.append_path 'assets'
        out
      end
    end

    default_widget_trees_to_add_to_sprockets.each do |widget_tree_root|
      out.parcels.add_widget_tree!(widget_tree_root)
    end
    out
  end

  def default_widget_trees_to_add_to_sprockets
    [ File.join(this_example_root, 'views') ]
  end
end
