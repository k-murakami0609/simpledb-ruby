# frozen_string_literal: true

require_relative "buffer"
class BufferMgr
  MAX_TIME = 10_000 # 10 seconds

  def initialize(fm, lm, num_buffs)
    @buffer_pool = Array.new(num_buffs) { Buffer.new(fm, lm) }
    @num_available = num_buffs
    @mutex = Mutex.new
    @full = ConditionVariable.new
  end

  def available
    @num_available
  end

  def flush_all(txnum)
    @buffer_pool.each do |buff|
      buff.flush if buff.modifying_tx == txnum
    end
  end

  def unpin(buff)
    buff.unpin
    return if buff.pinned?

    @num_available += 1
    @full.signal
  end

  def pin(blk)
    timestamp = Time.now.to_i * 1000 # milliseconds
    @mutex.synchronize do
      buff = try_to_pin(blk)
      while buff.nil? && !waiting_too_long(timestamp)
        @full.wait(@mutex, MAX_TIME / 1000.0)
        buff = try_to_pin(blk)
      end
      raise "BufferAbortException" if buff.nil?

      buff
    end
  end

  private

  def waiting_too_long(start_time)
    (Time.now.to_i * 1000) - start_time > MAX_TIME
  end

  def try_to_pin(blk)
    buff = find_existing_buffer(blk)
    if buff.nil?
      buff = choose_unpinned_buffer
      return nil if buff.nil?

      buff.assign_to_block(blk)
    end
    @num_available -= 1 unless buff.pinned?
    buff.pin
    buff
  end

  def find_existing_buffer(blk)
    @buffer_pool.find { |buff| buff.block && buff.block == blk }
  end

  def choose_unpinned_buffer
    @buffer_pool.find { |buff| !buff.pinned? }
  end
end
