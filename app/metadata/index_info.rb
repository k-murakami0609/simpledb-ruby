# frozen_string_literal: true

class IndexInfo
  attr_accessor :index_name, :field_name, :transaction, :table_schema, :index_layout, :stat_info

  def initialize(index_name, field_name, table_schema, transaction, stat_info)
    @index_name = index_name
    @field_name = field_name
    @transaction = transaction
    @table_schema = table_schema
    @index_layout = create_index_layout
    @stat_info = stat_info
  end

  def open
    HashIndex.new(@transaction, @index_name, @index_layout)
    # BTreeIndex.new(transaction, index_name, index_layout)  # Uncomment if using BTreeIndex
  end

  def blocks_accessed
    records_per_block = @transaction.block_size / @index_layout.slot_size
    num_blocks = @stat_info.records_output / records_per_block
    HashIndex.search_cost(num_blocks, records_per_block)
    # BTreeIndex.search_cost(num_blocks, records_per_block)  # Uncomment if using BTreeIndex
  end

  def records_output
    @stat_info.records_output / @stat_info.distinct_values(field_name)
  end

  def distinct_values(field_name)
    (@field_name == field_name) ? 1 : stat_info.distinct_values(@field_name)
  end

  private

  def create_index_layout
    schema = Schema.new
    schema.add_int_field("block")
    schema.add_int_field("id")
    if table_schema.type(field_name) == :integer
      schema.add_int_field("dataVal")
    else
      field_length = table_schema.length(field_name)
      schema.add_string_field("dataVal", field_length)
    end
    Layout.new(schema)
  end
end
