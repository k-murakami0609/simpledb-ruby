# frozen_string_literal: true

class Expression
  attr_accessor :value

  def initialize(value_or_field)
    @value = value_or_field
  end

  def evaluate(scan)
    if @value.is_a? Constant
      @value
    else
      scan.get_value(@value)
    end
  end

  def applies_to?(schema)
    if @value.is_a? Constant
      true
    else
      schema.has_field?(@value)
    end
  end

  def to_s
    if @value.is_a? Constant
      @value.to_s
    else
      @value
    end
  end
end
