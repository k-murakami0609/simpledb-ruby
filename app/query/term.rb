# frozen_string_literal: true

class Term
  attr_accessor :left_hand_side, :right_hand_side

  def initialize(left_hand_side, right_hand_side)
    @left_hand_side = left_hand_side
    @right_hand_side = right_hand_side
  end

  def satisfied?(scan)
    left_value = left_hand_side.evaluate(scan)
    right_value = right_hand_side.evaluate(scan)
    left_value == right_value
  end

  def reduction_factor(plan)
    if left_hand_side.field_name? && right_hand_side.field_name?
      left_name = left_hand_side.as_field_name
      right_name = right_hand_side.as_field_name
      [plan.distinct_values(left_name), plan.distinct_values(right_name)].max
    elsif left_hand_side.field_name?
      left_name = left_hand_side.as_field_name
      plan.distinct_values(left_name)
    elsif right_hand_side.field_name?
      right_name = right_hand_side.as_field_name
      plan.distinct_values(right_name)
    else
      (left_hand_side.as_constant == right_hand_side.as_constant) ? 1 : Float::INFINITY
    end
  end

  def equates_with_constant(field_name)
    if left_hand_side.field_name? && left_hand_side.as_field_name == field_name && !right_hand_side.field_name?
      right_hand_side.as_constant
    elsif right_hand_side.field_name? && right_hand_side.as_field_name == field_name && !left_hand_side.field_name?
      left_hand_side.as_constant
    end
  end

  def equates_with_field(field_name)
    if left_hand_side.field_name? && left_hand_side.as_field_name == field_name && right_hand_side.field_name?
      right_hand_side.as_field_name
    elsif right_hand_side.field_name? && right_hand_side.as_field_name == field_name && left_hand_side.field_name?
      left_hand_side.as_field_name
    end
  end

  def applies_to?(schema)
    left_hand_side.applies_to?(schema) && right_hand_side.applies_to?(schema)
  end

  def to_s
    "#{left_hand_side}=#{right_hand_side}"
  end
end
