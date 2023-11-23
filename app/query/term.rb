# frozen_string_literal: true

class Term
  attr_accessor :left_hand_side, :right_hand_side

  def initialize(left_hand_side, right_hand_side)
    @left_hand_side = left_hand_side
    @right_hand_side = right_hand_side
  end

  def satisfied?(scan)
    left_hand_side.evaluate(scan) == right_hand_side.evaluate(scan)
  end

  def reduction_factor(plan)
    case [left_hand_side.value, right_hand_side.value]
    in [String => left_name, String => right_name]
      [plan.distinct_values(left_name), plan.distinct_values(right_name)].min
    in [String => left_name, Constant]
      plan.distinct_values(left_name)
    in [Constant, String => right_name]
      plan.distinct_values(right_name)
    else
      (left_hand_side.value == right_hand_side.value) ? 1 : Float::INFINITY
    end
  end

  def equates_with_constant(field_name)
    case [left_hand_side.value, right_hand_side.value]
    in [String => left, Constant => right] if left == field_name
      right
    in [Constant => left, String => right] if right == field_name
      left
    else
      nil
    end
  end

  def equates_with_field(field_name)
    case [left_hand_side.value, right_hand_side.value]
    in [String => left, String => right] if left == field_name
      right
    in [String => left, String => right] if right == field_name
      left
    else
      nil
    end
  end

  def applies_to?(schema)
    left_hand_side.applies_to?(schema) && right_hand_side.applies_to?(schema)
  end

  def to_s
    "#{left_hand_side}=#{right_hand_side}"
  end
end
