# frozen_string_literal: true

class MaxFunction
  def initialize(field_name)
    @field_name = field_name
  end

  def process_first(scan)
    @value = scan.get_value(@field_name)
  end

  def process_next(scan)
    new_value = scan.get_value(@field_name)
    @value = new_value if new_value > @value
  end

  def field_name
    "maxof#{@field_name}"
  end

  attr_reader :value
end
