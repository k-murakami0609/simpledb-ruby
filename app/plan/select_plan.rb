# frozen_string_literal: true

class SelectPlan
  attr_reader :plan, :predicate

  # クエリツリーに新しいセレクトノードを作成します。
  # @param plan [Plan] サブクエリ
  # @param predicate [Predicate] 条件
  def initialize(plan, predicate)
    @plan = plan
    @predicate = predicate
  end

  # このクエリに対するセレクトスキャンを作成します。
  def open
    scan = @plan.open
    SelectScan.new(scan, predicate)
  end

  # セレクトのブロックアクセス数を推定します。
  def blocks_accessed
    @plan.blocks_accessed
  end

  # セレクトの出力レコード数を推定します。
  def records_output
    @plan.records_output / @predicate.reduction_factor(@plan).to_int
  end

  # セレクトの異なるフィールド値の数を推定します。
  def distinct_values(field_name)
    if @predicate.equates_with_constant(field_name)
      1
    else
      field_name2 = @predicate.equates_with_field(field_name)
      if field_name2
        [@plan.distinct_values(field_name), @plan.distinct_values(field_name2)].min
      else
        @plan.distinct_values(field_name)
      end
    end
  end

  # セレクトのスキーマを返します。
  def schema
    @plan.schema
  end
end
