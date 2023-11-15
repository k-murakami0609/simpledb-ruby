# frozen_string_literal: true

# noinspection RubyClassVariableUsageInspection
class Transaction
  @@next_tx_num = 0
  END_OF_FILE = -1

  # クラスメソッド定義
  def self.next_tx_number
    @@next_tx_num += 1
  end

  def initialize(file_manager, log_manager, buffer_manager)
    @file_manager = file_manager
    @buffer_manager = buffer_manager
    @transaction_number = self.class.next_tx_number
    @recovery_manager = RecoveryManager.new(self, @transaction_number, log_manager, buffer_manager)
    @concurrency_manager = ConcurrencyManager.new
    @buffers = BufferList.new(bm)
  end

  def commit
    @recovery_manager.commit
    puts "transaction #{@transaction_number} committed"
    @concurrency_manager.release
    @buffers.unpin_all
  end

  def rollback
    @recovery_manager.rollback
    puts "transaction #{@transaction_number} rolled back"
    @concurrency_manager.release
    @buffers.unpin_all
  end

  def recover
    @buffer_manager.flush_all(@transaction_number)
    @recovery_manager.recover
  end

  def pin(block_id)
    @buffers.pin(block_id)
  end

  def unpin(block_id)
    @buffers.unpin(block_id)
  end

  def get_int(block_id, offset)
    @concurrency_manager.s_lock(block_id)
    buffer = @buffers.get_buffer(block_id)
    buffer.contents.get_int(offset)
  end

  def get_string(block_id, offset)
    @concurrency_manager.s_lock(block_id)
    buffer = @buffers.get_buffer(block_id)
    buffer.contents.get_string(offset)
  end

  def set_int(block_id, offset, value, ok_to_log)
    @concurrency_manager.x_lock(block_id)
    buffer = @buffers.get_buffer(block_id)
    lsn = -1
    lsn = @recovery_manager.set_int(buffer, offset, value) if ok_to_log
    page = buffer.contents
    page.set_int(offset, value)
    buffer.set_modified(@transaction_number, lsn)
  end

  def set_string(block_id, offset, value, ok_to_log)
    @concurrency_manager.x_lock(block_id)
    buffer = @buffers.get_buffer(block_id)
    lsn = -1
    lsn = @recovery_manager.set_string(buffer, offset, value) if ok_to_log
    page = buffer.contents
    page.set_string(offset, value)
    buffer.set_modified(@transaction_number, lsn)
  end

  def size(file_name)
    dummy_block_id = BlockId.new(file_name, END_OF_FILE)
    @concurrency_manager.s_lock(dummy_block_id)
    @file_manager.length(file_name)
  end

  def append(file_name)
    dummy_block_id = BlockId.new(file_name, END_OF_FILE)
    @concurrency_manager.x_lock(dummy_block_id)
    @file_manager.append(file_name)
  end

  def block_size
    @file_manager.block_size
  end

  def available_buffs
    @buffer_manager.available
  end
end
