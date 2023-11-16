# frozen_string_literal: true

class Buffer
  attr_accessor :contents, :block_id, :pins, :transaction_number, :lsn

  def initialize(file_manager, log_manager)
    @file_manager = file_manager
    @log_manager = log_manager
    @contents = Page.new(file_manager.block_size) # assuming a Page class is defined with a method block_size
    @block_id = nil
    @pins = 0
    @transaction_number = -1
    @lsn = -1
  end

  def set_modified(transaction_number, lsn)
    @transaction_number = transaction_number
    @lsn = lsn if lsn >= 0
  end

  def pinned?
    @pins.positive?
  end

  def modifying_tx
    @transaction_number
  end

  def assign_to_block(block_id)
    flush
    @block_id = block_id
    @file_manager.read(block_id, @contents)
    @pins = 0
  end

  def flush
    return unless @transaction_number >= 0

    @log_manager.flush(@lsn)
    block_id = @block_id
    throw "block_id is null. but flush" unless block_id
    @file_manager.write(block_id, @contents)
    @transaction_number = -1
  end

  def pin
    @pins += 1
  end

  def unpin
    @pins -= 1
  end
end
