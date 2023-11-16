# frozen_string_literal: true

require_relative "lock_table"

# transaction ごとにインスタンスが生成される
# noinspection RubyClassVariableUsageInspection
class ConcurrencyManager
  @@lock_table = LockTable.new

  module LockType
    X_LOCK = "X"
    S_LOCK = "S"
  end

  def initialize
    @locks = {}
  end

  def s_lock(block_id)
    unless @locks.key?(block_id)
      @@lock_table.s_lock(block_id)
      @locks[block_id] = LockType::S_LOCK
    end
  end

  def x_lock(block_id)
    unless x_lock?(block_id)
      s_lock(block_id)
      @@lock_table.x_lock(block_id)
      @locks[block_id] = LockType::X_LOCK
    end
  end

  # ロックテーブルに要求して、すべてのロックを解放します。
  def release
    @locks.keys.each do |block_id|
      @@lock_table.unlock(block_id)
    end
    @locks.clear
  end

  private

  def x_lock?(block_id)
    @locks[block_id].equal?(LockType::X_LOCK)
  end
end
