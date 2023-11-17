# frozen_string_literal: true

class StatManager
  def initialize(table_manager, transaction)
    @table_manager = table_manager
    @table_stats = {}
    @num_calls = 0
    refresh_statistics(transaction)
  end

  def get_stat_info(table_name, layout, transaction)
    @num_calls += 1
    refresh_statistics(transaction) if @num_calls > 100
    stat_info = @table_stats[table_name]
    if stat_info.nil?
      stat_info = calculate_table_stats(table_name, layout, transaction)
      @table_stats[table_name] = stat_info
    end
    stat_info
  end

  private

  def refresh_statistics(transaction)
    @table_stats.clear
    @num_calls = 0
    table_catalog_layout = @table_manager.get_layout("tableCatalog", transaction)
    table_catalog = TableScan.new(transaction, "tableCatalog", table_catalog_layout)
    while table_catalog.next?
      table_name = table_catalog.get_string("tableName")
      layout = @table_manager.get_layout(table_name, transaction)
      stat_info = calculate_table_stats(table_name, layout, transaction)
      @table_stats[table_name] = stat_info
    end
    table_catalog.close
  end

  def calculate_table_stats(table_name, layout, transaction)
    num_records = 0
    num_blocks = 0
    table_scan = TableScan.new(transaction, table_name, layout)
    while table_scan.next?
      num_records += 1
      num_blocks = table_scan.get_rid&.block_number&.+ 1
    end
    table_scan.close
    StatInfo.new(num_blocks, num_records)
  end
end

class StatInfo
  attr_accessor :num_blocks, :num_records

  def initialize(num_blocks, num_records)
    @num_blocks = num_blocks
    @num_records = num_records
  end
end
