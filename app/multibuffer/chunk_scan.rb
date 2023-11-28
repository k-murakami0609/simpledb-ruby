# frozen_string_literal: true

class ChunkScan
  def initialize(transaction, file_name, layout, start_block_number, end_block_number)
    @transaction = transaction
    @file_name = file_name
    @layout = layout
    @start_block_number = start_block_number
    @end_block_number = end_block_number
    @buffers = []
    (@start_block_number..@end_block_number).each do |i|
      block_id = BlockId.new(@file_name, i)
      @buffers << RecordPage.new(@transaction, block_id, @layout)
    end
    move_to_block(@start_block_number)
  end

  def close
    @buffers.each_with_index do |_, i|
      block_id = BlockId.new(@file_name, @start_block_number + i)
      @transaction.unpin(block_id)
    end
  end

  def before_first
    move_to_block(@start_block_number)
  end

  def next
    @current_slot = @record_page.next_after(@current_slot)
    while @current_slot < 0
      return false if @current_block_number == @end_block_number
      move_to_block(@record_page.block_id.block_number + 1)
      @current_slot = @record_page.next_after(@current_slot)
    end
    true
  end

  def get_int(field_name)
    @record_page.get_int(@current_slot, field_name)
  end

  def get_string(field_name)
    @record_page.get_string(@current_slot, field_name)
  end

  def get_value(field_name)
    if @layout.schema.type(field_name) == Schema::FieldInfo::Type::INTEGER
      Constant.new(get_int(field_name))
    else
      Constant.new(get_string(field_name))
    end
  end

  def has_field?(field_name)
    @layout.schema.has_field?(field_name)
  end

  private

  def move_to_block(block_number)
    @current_block_number = block_number
    @record_page = @buffers[@current_block_number - @start_block_number]
    @current_slot = -1
  end
end
