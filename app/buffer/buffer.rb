# frozen_string_literal: true

require_relative "../file/page"

class Buffer
  attr_accessor :contents, :blk, :pins, :transaction_number, :lsn

  def initialize(file_manager, log_manager)
    @file_manager = file_manager
    @log_manager = log_manager
    @contents = Page.new(file_manager.block_size) # assuming a Page class is defined with a method block_size
    @blk = nil
    @pins = 0
    @transaction_number = -1
    @lsn = -1
  end

  def block
    @blk
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

  def assign_to_block(b)
    flush
    @blk = b
    @file_manager.read(@blk, @contents)
    @pins = 0
  end

  def flush
    return unless @transaction_number >= 0

    @log_manager.flush(@lsn)
    @file_manager.write(@blk, @contents)
    @transaction_number = -1
  end

  def pin
    @pins += 1
  end

  def unpin
    @pins -= 1
  end
end
