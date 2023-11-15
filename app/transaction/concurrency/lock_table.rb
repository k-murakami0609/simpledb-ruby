# frozen_string_literal: true

class LockTable
  MAX_LOCKS = 10_000  # 10 seconds
  def initialize
    # block_id => value(0: no lock, 1+: s_lock, -1: x_lock)
    @locks = {}

    @mutex = Mutex.new
    @full = ConditionVariable.new
  end

  def s_lock(block_id)
    timestamp = Time.now.to_i * 1000 # milliseconds

    @mutex.synchronize do
      while x_lock?(block_id) && !waiting_too_long(timestamp)
        @full.wait(@mutex, MAX_LOCKS / 1000.0)
      end
      raise "LockAbortException" if x_lock?(block_id)

      value = get_lock_value(block_id)
      @locks[block_id] = value + 1
    end
  end

  def x_lock(block_id)
    timestamp = Time.now.to_i * 1000 # milliseconds

    @mutex.synchronize do
      while other_s_lock?(block_id) && !waiting_too_long(timestamp)
        @full.wait(@mutex, MAX_LOCKS / 1000.0)
      end
      raise "LockAbortException" if other_s_lock?(block_id)

      @locks[block_id] = -1
    end
  end

  def unlock(block_id)
    value = get_lock_value(block_id)

    if value > 1
      @locks[block_id] = value - 1
    else
      @locks.delete(block_id)
      @full.signal
    end
  end

  private

  def x_lock?(block_id)
    get_lock_value(block_id) < 0
  end

  def other_s_lock?(block_id)
    get_lock_value(block_id) > 1
  end

  def get_lock_value(block_id)
    @locks[block_id]&.value || 0
  end

  def waiting_too_long(start_time)
    (Time.now.to_i * 1000) - start_time > MAX_TIME
  end
end
