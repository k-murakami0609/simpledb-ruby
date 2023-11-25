# frozen_string_literal: true

class RecordPage
  module SlotState
    EMPTY = 0
    USED = 1
  end

  attr_reader :block_id

  def initialize(transaction, block_id, layout)
    @transaction = transaction
    @block_id = block_id
    @layout = layout
    @transaction.pin(block_id)
  end

  # 指定されたスロットの指定されたフィールドに格納されている整数値を返します。
  def get_int(slot, field_name)
    field_position = offset(slot) + @layout.offset(field_name)
    @transaction.get_int(@block_id, field_position)
  end

  # 指定されたスロットの指定されたフィールドに格納されている文字列値を返します。
  def get_string(slot, field_name)
    field_position = offset(slot) + @layout.offset(field_name)
    @transaction.get_string(@block_id, field_position)
  end

  # 指定されたスロットの指定されたフィールドに整数値を格納します。
  def set_int(slot, field_name, value)
    field_position = offset(slot) + @layout.offset(field_name)
    @transaction.set_int(@block_id, field_position, value, true)
  end

  # 指定されたスロットの指定されたフィールドに文字列値を格納します。
  def set_string(slot, field_name, value)
    field_position = offset(slot) + @layout.offset(field_name)
    @transaction.set_string(@block_id, field_position, value, true)
  end

  def delete(slot)
    set_slot_state(slot, SlotState::EMPTY)
  end

  # 新しいレコードブロックをフォーマットします。これらの値はログに記録されるべきではありません。
  def format
    slot = 0
    while valid_slot?(slot)
      LoggerManager.logger.debug("RecordPage.format: block_id=#{@block_id} slot=#{slot} slot_size=#{@layout.slot_size} offset=#{offset(slot)}")
      @transaction.set_int(@block_id, offset(slot), SlotState::EMPTY, false)
      schema = @layout.schema
      schema.field_names.each do |field_name|
        field_position = offset(slot) + @layout.offset(field_name)
        case schema.type(field_name)
        when Schema::FieldInfo::Type::INTEGER
          @transaction.set_int(@block_id, field_position, 0, false)
        when Schema::FieldInfo::Type::VARCHAR
          @transaction.set_string(@block_id, field_position, "", false)
        else
          raise "unrecognized field type"
        end
      end
      slot += 1
    end
  end

  def next_after(slot)
    search_after(slot, SlotState::USED)
  end

  def insert_after(slot)
    new_slot = search_after(slot, SlotState::EMPTY)
    set_slot_state(new_slot, SlotState::USED) if new_slot >= 0
    new_slot
  end

  private

  # レコードの空/使用中フラグを設定します。
  def set_slot_state(slot, state)
    @transaction.set_int(@block_id, offset(slot), state, true)
  end

  def search_after(slot, state)
    slot += 1
    while valid_slot?(slot)
      return slot if @transaction.get_int(@block_id, offset(slot)) == state
      slot += 1
    end
    -1
  end

  def valid_slot?(slot)
    offset(slot + 1) <= @transaction.block_size
  end

  def offset(slot)
    slot * @layout.slot_size
  end
end
