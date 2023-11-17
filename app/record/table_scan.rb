# frozen_string_literal: true

class TableScan
  attr_reader :current_slot

  def initialize(transaction, table_name, layout)
    @transaction = transaction
    @layout = layout
    @file_name = "#{table_name}.tbl"
    @record_page = if @transaction.size(@file_name) == 0
      move_to_new_block
    else
      move_to_block(0)
    end
  end

  def before_first
    @record_page = move_to_block(0)
  end

  def next?
    @current_slot = @record_page.next_after(@current_slot)
    while @current_slot < 0
      return false if at_last_block?
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

  def get_val(field_name)
    if @layout.schema.type(field_name) == :integer
      get_int(field_name)
    else
      get_string(field_name)
    end
  end

  def has_field?(field_name)
    @layout.schema.has_field?(field_name)
  end

  def close
    @transaction.unpin(@record_page.block_id) if @record_page
  end

  def set_int(field_name, val)
    @record_page.set_int(@current_slot, field_name, val)
  end

  def set_string(field_name, val)
    @record_page.set_string(@current_slot, field_name, val)
  end

  def set_val(field_name, val)
    if @layout.schema.type(field_name) == :integer
      set_int(field_name, val.to_i)
    else
      set_string(field_name, val.to_s)
    end
  end

  def insert
    @current_slot = @record_page.insert_after(@current_slot)
    while @current_slot < 0
      @record_page = if at_last_block?
        move_to_new_block
      else
        move_to_block(@record_page.block_id.block_number + 1)
      end
      @current_slot = @record_page.insert_after(@current_slot)
    end
  end

  def delete
    @record_page.delete(@current_slot)
  end

  def move_to_rid(rid)
    close
    block_id = BlockId.new(@file_name, rid.block_number)
    @record_page = RecordPage.new(@transaction, block_id, @layout)
    @current_slot = rid.slot
  end

  def get_rid
    RecordId.new(@record_page.block_id.block_number, @current_slot)
  end

  private

  def move_to_block(block_number)
    close
    block_id = BlockId.new(@file_name, block_number)
    record_page = RecordPage.new(@transaction, block_id, @layout)
    @current_slot = -1

    record_page
  end

  def move_to_new_block
    close
    block_id = @transaction.append(@file_name)
    record_page = RecordPage.new(@transaction, block_id, @layout)
    record_page.format
    @current_slot = -1

    record_page
  end

  def at_last_block?
    @record_page.block_id.block_number == @transaction.size(@file_name) - 1
  end
end
