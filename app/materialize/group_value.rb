# frozen_string_literal: true

class GroupValue
  attr_reader :name_to_values

  def initialize(scan, fields)
    @name_to_values = {}
    fields.each do |field_name|
      @name_to_values[field_name] = scan.get_value(field_name)
    end
  end

  def get_value(field_name)
    @name_to_values[field_name]
  end

  def ==(other)
    return false unless other.is_a?(GroupValue)

    @name_to_values.all? do |field_name, value|
      other_value = other.get_value(field_name)
      value == other_value unless other_value.nil?
    end
  end

  def hash
    @name_to_values.values.sum(&:hash)
  end
end
