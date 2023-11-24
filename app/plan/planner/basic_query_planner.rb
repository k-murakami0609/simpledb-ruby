# frozen_string_literal: true

class BasicQueryPlanner
  attr_reader :metadata_manager

  # 新しいBasicQueryPlannerを作成します。
  # @param metadata_manager [MetadataManager] メタデータマネージャー
  def initialize(metadata_manager)
    @metadata_manager = metadata_manager
  end

  # クエリ計画を作成します。
  # @param query_data [QueryData] クエリデータ
  # @param transaction [Transaction] トランザクション
  # @return [Plan] 作成されたクエリ計画
  def create_plan(query_data, transaction)
    # ステップ1: 各テーブルまたはビューに対して計画を作成
    plans = query_data.table_names.map do |table_name|
      view_definition = metadata_manager.get_view_definition(table_name, transaction)
      if view_definition
        # ビューのクエリを再帰的に計画
        parser = Parser.new(view_definition)
        view_data = parser.query
        create_plan(view_data, transaction)
      else
        TablePlan.new(transaction, table_name, metadata_manager)
      end
    end

    # ステップ2: すべてのテーブル計画の積を作成
    plan = plans.shift
    plans.each { |next_plan| plan = ProductPlan.new(plan, next_plan) }

    # ステップ3: 述語に基づいて選択計画を追加
    plan = SelectPlan.new(plan, query_data.predicate)

    # ステップ4: フィールド名に基づいて投影計画を作成
    ProjectPlan.new(plan, query_data.fields)
  end
end
