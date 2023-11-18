# frozen_string_literal: true

class IndexManager
  attr_accessor :layout, :table_manager, :stat_manager

  def initialize(is_new, table_manager, stat_manager, transaction)
    if is_new
      schema = Schema.new
      schema.add_string_field("indexName", MAX_NAME)
      schema.add_string_field("tableName", MAX_NAME)
      schema.add_string_field("fieldName", MAX_NAME)
      table_manager.create_table("indexCatalog", schema, transaction)
    end
    @table_manager = table_manager
    @stat_manager = stat_manager
    @layout = table_manager.get_layout("indexCatalog", transaction)
  end

  def create_index(index_name, table_name, field_name, transaction)
    table_scan = TableScan.new(transaction, "indexCatalog", layout)
    table_scan.insert
    table_scan.set_string("indexName", index_name)
    table_scan.set_string("tableName", table_name)
    table_scan.set_string("fieldName", field_name)
    table_scan.close
  end

  def get_index_info(table_name, transaction)
    result = {}
    table_scan = TableScan.new(transaction, "indexCatalog", layout)
    while table_scan.next?
      if table_scan.get_string("tableName") == table_name
        index_name = table_scan.get_string("indexName")
        field_name = table_scan.get_string("fieldName")
        table_layout = table_manager.get_layout(table_name, transaction)
        stat_info = stat_manager.get_stat_info(table_name, table_layout, transaction)
        index_info = IndexInfo.new(index_name, field_name, table_layout.schema, transaction, stat_info)
        result[field_name] = index_info
      end
    end
    table_scan.close
    result
  end
end
