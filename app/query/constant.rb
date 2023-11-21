# frozen_string_literal: true

class Constant
  include Comparable

  attr_accessor :integer_value, :string_value

  def initialize(value)
    if value.is_a?(Integer)
      @integer_value = value
      @string_value = nil
    elsif value.is_a?(String)
      @integer_value = nil
      @string_value = value
    else
      raise ArgumentError, "Invalid type for Constant"
    end
  end

  def as_integer
    integer_value
  end

  def as_string
    string_value
  end

  def <=>(other)
    if integer_value
      integer_value <=> other.as_integer
    else
      string_value <=> other.as_string
    end
  end

  def ==(other)
    if other.is_a?(Constant)
      (integer_value && integer_value == other.as_integer) ||
        (string_value && string_value == other.as_string)
    else
      false
    end
  end

  def hash
    (integer_value ? integer_value.hash : string_value.hash)
  end

  def to_s
    (integer_value ? integer_value.to_s : string_value.to_s)
  end
end
