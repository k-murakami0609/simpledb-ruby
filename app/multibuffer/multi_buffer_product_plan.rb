# frozen_string_literal: true

class MultiBufferProductPlan
  attr_reader :schema

  def initialize(transaction, left_hand_side, right_hand_side)
    @transaction = transaction
    @left_hand_side = MaterializePlan.new(transaction, left_hand_side)
    @right_hand_side = right_hand_side
    @schema = Schema.new
    @schema.add_all(left_hand_side.schema)
    @schema.add_all(right_hand_side.schema)
  end

  def open
    left_scan = @left_hand_side.open
    temp_table = copy_records_from(@right_hand_side)
    MultibufferProductScan.new(@transaction, left_scan, temp_table.table_name, temp_table.layout)
  end

  def blocks_accessed
    available = @transaction.available_buffers
    size = MaterializePlan.new(@transaction, @right_hand_side).blocks_accessed
    num_chunks = size / available
    @right_hand_side.blocks_accessed + (@left_hand_side.blocks_accessed * num_chunks)
  end

  def records_output
    @left_hand_side.records_output * @right_hand_side.records_output
  end

  def distinct_values(field_name)
    if @left_hand_side.schema.has_field(field_name)
      @left_hand_side.distinct_values(field_name)
    else
      @right_hand_side.distinct_values(field_name)
    end
  end

  private

  def copy_records_from(plan)
    source_scan = plan.open
    schema = plan.schema
    temp_table = TempTable.new(@transaction, schema)
    dest_scan = temp_table.open_update_scan
    while source_scan.next
      dest_scan.insert
      schema.fields.each do |field_name|
        dest_scan.set_val(field_name, source_scan.get_val(field_name))
      end
    end
    source_scan.close
    dest_scan.close
    temp_table
  end
end
