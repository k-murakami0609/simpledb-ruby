# frozen_string_literal: true

class Expression
  attr_accessor :value, :field_name

  def initialize(value_or_field)
    if value_or_field.is_a?(Constant)
      @value = value_or_field
      @field_name = nil
    else
      @value = nil
      @field_name = value_or_field
    end
  end

  def evaluate(scan)
    value || scan.get_value(field_name)
  end

  def field_name?
    !field_name.nil?
  end

  def as_constant
    value
  end

  def as_field_name
    field_name
  end

  def applies_to?(schema)
    value ? true : schema.has_field?(field_name)
  end

  def to_s
    if value
      value.to_s
    else
      field_name || ""
    end
  end
end
