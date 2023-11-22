# frozen_string_literal: true

class ProjectPlan
  attr_reader :plan, :schema

  def initialize(plan, field_name_list)
    @plan = plan
    @schema = Schema.new
    field_name_list.each do |field_name|
      @schema.add(field_name, plan.schema)
    end
  end

  # このクエリに対するプロジェクトスキャンを作成します。
  def open
    scan = plan.open
    ProjectScan.new(scan, @schema.field_names)
  end

  # プロジェクションのブロックアクセス数を推定します。
  # これは基礎となるクエリと同じです。
  def blocks_accessed
    @plan.blocks_accessed
  end

  # プロジェクションの出力レコード数を推定します。
  # これは基礎となるクエリと同じです。
  def records_output
    @plan.records_output
  end

  # プロジェクションの異なるフィールド値の数を推定します。
  # これは基礎となるクエリと同じです。
  def distinct_values(field_name)
    @plan.distinct_values(field_name)
  end
end
