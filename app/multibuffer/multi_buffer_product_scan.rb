# frozen_string_literal: true

class MultiBufferProductScan
  def initialize(transaction, left_hand_side_scan, table_name, layout)
    @transaction = transaction
    @left_hand_side_scan = left_hand_side_scan
    @filename = "#{table_name}.tbl"
    @layout = layout
    @file_size = @transaction.size(@filename)
    available = @transaction.available_buffs
    @chunk_size = BufferNeeds.best_factor(available, @file_size)
    before_first
  end

  def before_first
    @next_block_number = 0
    use_next_chunk
  end

  def next?
    until @product_scan.next?
      return false unless use_next_chunk
    end
    true
  end

  def close
    @product_scan.close
  end

  def get_value(field_name)
    @product_scan.get_value(field_name)
  end

  def get_int(field_name)
    @product_scan.get_int(field_name)
  end

  def get_string(field_name)
    @product_scan.get_string(field_name)
  end

  def has_field?(field_name)
    @product_scan.has_field?(field_name)
  end

  private

  def use_next_chunk
    return false if @next_block_number >= @file_size
    @right_hand_side_scan&.close
    end_number = @next_block_number + @chunk_size - 1
    end_number = @file_size - 1 if end_number >= @file_size
    @right_hand_side_scan = ChunkScan.new(@transaction, @filename, @layout, @next_block_number, end_number)
    @left_hand_side_scan.before_first
    @product_scan = ProductScan.new(@left_hand_side_scan, @right_hand_side_scan)
    @next_block_number = end_number + 1
    true
  end
end
