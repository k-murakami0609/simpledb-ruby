# frozen_string_literal: true

class Planner
  attr_reader :query_planner, :update_planner

  # 新しいプランナーを作成します。
  # @param query_planner [QueryPlanner] クエリプランナー
  # @param update_planner [UpdatePlanner] 更新プランナー
  def initialize(query_planner, update_planner)
    @query_planner = query_planner
    @update_planner = update_planner
  end

  # SQL select文の計画を作成します。
  # @param query [String] SQLクエリ文字列
  # @param transaction [Transaction] トランザクション
  # @return [Plan] クエリ計画に対応するスキャン
  def create_query_plan(query, transaction)
    parser = Parser.new(query)
    query_data = parser.query
    verify_query(query_data)
    @query_planner.create_plan(query_data, transaction)
  end

  # SQLのinsert, delete, modify, create文を実行します。
  # @param command [String] SQL更新文字列
  # @param transaction [Transaction] トランザクション
  # @return [Integer] 影響を受けたレコード数
  def execute_update(command, transaction)
    parser = Parser.new(command)
    data = parser.update_cmd
    verify_update(data)

    case data
    when InsertData
      @update_planner.execute_insert(data, transaction)
    when DeleteData
      @update_planner.execute_delete(data, transaction)
    when ModifyData
      @update_planner.execute_modify(data, transaction)
    when CreateTableData
      @update_planner.execute_create_table(data, transaction)
    when CreateViewData
      @update_planner.execute_create_view(data, transaction)
    when CreateIndexData
      @update_planner.execute_create_index(data, transaction)
    else
      0
    end
  end

  # SimpleDBではクエリの検証を行いませんが、本来は行うべきです。
  private def verify_query(query_data)
    # 検証ロジックを実装
  end

  # SimpleDBでは更新の検証を行いませんが、本来は行うべきです。
  private def verify_update(data)
    # 検証ロジックを実装
  end
end
