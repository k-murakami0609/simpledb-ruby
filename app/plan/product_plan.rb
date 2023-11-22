# frozen_string_literal: true

class ProductPlan
  attr_reader :plan1, :plan2, :schema

  # クエリツリーに新しいプロダクトノードを作成します。
  # @param plan1 [Plan] 左側のサブクエリ
  # @param plan2 [Plan] 右側のサブクエリ
  def initialize(plan1, plan2)
    @plan1 = plan1
    @plan2 = plan2
    @schema = Schema.new
    schema.add_all(plan1.schema)
    schema.add_all(plan2.schema)
  end

  # このクエリに対するプロダクトスキャンを作成します。
  def open
    scan1 = @plan1.open
    scan2 = @plan2.open
    ProductScan.new(scan1, scan2)
  end

  # プロダクトのブロックアクセス数を推定します。
  def blocks_accessed
    @plan1.blocks_accessed + (@plan1.records_output * @plan2.blocks_accessed)
  end

  # プロダクトの出力レコード数を推定します。
  def records_output
    @plan1.records_output * @plan2.records_output
  end

  # プロダクトの異なるフィールド値の数を推定します。
  def distinct_values(field_name)
    if @plan1.schema.has_field?(field_name)
      @plan1.distinct_values(field_name)
    else
      @plan2.distinct_values(field_name)
    end
  end
end
