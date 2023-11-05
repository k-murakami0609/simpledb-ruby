# frozen_string_literal: true

require_relative "buffer"
class BufferManager
  MAX_TIME = 10_000 # 10 seconds

  def initialize(file_manager, log_manager, number_buffers)
    @buffer_pool = Array.new(number_buffers) { Buffer.new(file_manager, log_manager) }
    @num_available = number_buffers
    @mutex = Mutex.new
    @full = ConditionVariable.new
  end

  def available
    @num_available
  end

  def flush_all(transaction_number)
    @buffer_pool.each do |buffer|
      buffer.flush if buffer.modifying_tx == transaction_number
    end
  end

  def unpin(buffer)
    buffer.unpin
    return if buffer.pinned?

    @num_available += 1
    @full.signal
  end

  def pin(blk)
    timestamp = Time.now.to_i * 1000 # milliseconds
    @mutex.synchronize do
      buffer = try_to_pin(blk)
      while buffer.nil? && !waiting_too_long(timestamp)
        @full.wait(@mutex, MAX_TIME / 1000.0)
        buffer = try_to_pin(blk)
      end
      raise "BufferAbortException" if buffer.nil?

      buffer
    end
  end

  private

  def waiting_too_long(start_time)
    (Time.now.to_i * 1000) - start_time > MAX_TIME
  end

  def try_to_pin(blk)
    buffer = find_existing_buffer(blk)
    if buffer.nil?
      buffer = choose_unpinned_buffer
      return nil if buffer.nil?

      buffer.assign_to_block(blk)
    end
    @num_available -= 1 unless buffer.pinned?
    buffer.pin
    buffer
  end

  def find_existing_buffer(blk)
    @buffer_pool.find { |buffer| buffer.block && buffer.block == blk }
  end

  def choose_unpinned_buffer
    @buffer_pool.find { |buffer| !buffer.pinned? }
  end
end
