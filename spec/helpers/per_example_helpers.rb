module PerExampleHelpers
  def set_up_per_example_data!(example)
    @per_example_data = {
      :example => example
    }
  end

  def per_example_data
    (@per_example_data || raise("#set_up_per_example_data! was not called!"))
  end

  def this_example
    per_example_data[:example]
  end
end
