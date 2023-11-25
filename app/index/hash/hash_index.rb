# frozen_string_literal: true

class HashIndex
  NUM_BUCKETS = 100
  attr_accessor :transaction, :index_name, :layout, :search_key, :table_scan

  def initialize(transaction, index_name, layout)
    @transaction = transaction
    @index_name = index_name
    @layout = layout
    @search_key = Constant.new("default")
    @table_scan = TableScan.new(transaction, "default", layout)
  end

  def before_first(search_key)
    close
    @search_key = search_key
    bucket = search_key.hash % NUM_BUCKETS
    table_name = "#{index_name}#{bucket}"
    @table_scan = TableScan.new(transaction, table_name, layout)
  end

  def next?
    while @table_scan.next?
      return true if @table_scan.get_value("dataVal") == search_key
    end
    false
  end

  def get_data_record_id
    block_number = @table_scan.get_int("block")
    id = @table_scan.get_int("id")
    RecordId.new(block_number, id)
  end

  def insert(val, record_id)
    before_first(val)
    @table_scan.insert
    @table_scan.set_int("block", record_id.block_number)
    @table_scan.set_int("id", record_id.slot)
    @table_scan.set_value("dataVal", val)
  end

  def delete(val, record_id)
    before_first(val)
    while next?
      if get_data_record_id == record_id
        @table_scan.delete
        return
      end
    end
  end

  def close
    @table_scan.close
  end

  def self.search_cost(num_blocks, records_per_block)
    num_blocks / NUM_BUCKETS
  end
end
