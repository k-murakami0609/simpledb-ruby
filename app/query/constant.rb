# frozen_string_literal: true

class Constant
  include Comparable

  attr_accessor :value

  def initialize(value)
    if value.is_a?(Integer) || value.is_a?(String)
      @value = value
    else
      raise ArgumentError, "Invalid type for Constant"
    end
  end

  def <=>(other)
    value <=> other.value
  end

  def ==(other)
    if other.is_a?(Constant)
      value == other.value
    else
      false
    end
  end
end
