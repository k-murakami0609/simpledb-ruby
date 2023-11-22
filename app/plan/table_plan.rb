# frozen_string_literal: true

class TablePlan
  attr_reader :table_name, :transaction, :layout, :stat_info

  # 指定されたテーブルに対応するクエリツリーのリーフノードを作成します。
  # @param table_name [String] テーブルの名前
  # @param transaction [Transaction] 呼び出し元のトランザクション
  def initialize(transaction, table_name, metadata_manager)
    @table_name = table_name
    @transaction = transaction
    @layout = metadata_manager.get_layout(table_name, transaction)
    @stat_info = metadata_manager.get_stat_info(table_name, layout, transaction)
  end

  # このクエリに対するテーブルスキャンを作成します。
  def open
    TableScan.new(transaction, table_name, layout)
  end

  # テーブルのブロックアクセス数を推定します。
  # 統計マネージャから取得可能です。
  def blocks_accessed
    @stat_info.blocks_accessed
  end

  # テーブル内のレコード数を推定します。
  # 統計マネージャから取得可能です。
  def records_output
    @stat_info.records_output
  end

  # テーブル内の特定フィールドの異なる値の数を推定します。
  # 統計マネージャから取得可能です。
  def distinct_values(field_name)
    @stat_info.distinct_values(field_name)
  end

  # テーブルのスキーマを決定します。
  # カタログマネージャから取得可能です。
  def schema
    @layout.schema
  end
end
