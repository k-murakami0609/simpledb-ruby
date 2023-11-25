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
      @record_page = move_to_block(@record_page.block_id.block_number + 1)
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

  def close
    @transaction.unpin(@record_page.block_id) if @record_page
  end

  def set_int(field_name, val)
    LoggerManager.logger.debug("TableScan.set_int: field_name=#{field_name} val=#{val}")
    @record_page.set_int(@current_slot, field_name, val)
  end

  def set_string(field_name, val)
    LoggerManager.logger.debug("TableScan.set_string: field_name=#{field_name} val=#{val}")
    @record_page.set_string(@current_slot, field_name, val)
  end

  def set_value(field_name, val)
    LoggerManager.logger.debug("TableScan.set_value: field_name=#{field_name} val=#{val} type=#{@layout.schema.type(field_name)}")
    if @layout.schema.type(field_name) == Schema::FieldInfo::Type::INTEGER
      set_int(field_name, val.value.to_i)
    else
      set_string(field_name, val.value.to_s)
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

  def move_to_record_id(record_id)
    close
    block_id = BlockId.new(@file_name, record_id.block_number)
    @record_page = RecordPage.new(@transaction, block_id, @layout)
    @current_slot = record_id.slot
  end

  def get_record_id
    RecordId.new(@record_page.block_id.block_number, @current_slot)
  end

  private

  def move_to_block(block_number)
    close
    block_id = BlockId.new(@file_name, block_number)
    record_page = RecordPage.new(@transaction, block_id, @layout)
    @current_slot = -1

    LoggerManager.logger.debug("TableScan.move_to_block: block_id=#{block_id} block_number=#{block_number}")

    record_page
  end

  def move_to_new_block
    close
    block_id = @transaction.append(@file_name)
    record_page = RecordPage.new(@transaction, block_id, @layout)
    record_page.format
    @current_slot = -1

    LoggerManager.logger.debug("TableScan.move_to_new_block: block_id=#{block_id}")

    record_page
  end

  def at_last_block?
    @record_page.block_id.block_number == @transaction.size(@file_name) - 1
  end
end
