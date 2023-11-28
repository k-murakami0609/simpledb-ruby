# frozen_string_literal: true

class CountFunction
  attr_reader :count

  def initialize(field_name)
    @field_name = field_name
    @count = 0
  end

  def process_first(scan)
    @count = 1
  end

  def process_next(scan)
    @count += 1
  end

  def field_name
    "countof#{field_name}"
  end

  def value
    Constant.new(count)
  end
end
