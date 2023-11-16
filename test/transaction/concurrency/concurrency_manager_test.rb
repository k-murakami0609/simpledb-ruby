# frozen_string_literal: true

require "minitest/autorun"
require "timecop"

require_relative "../../../app/server/simple_db"

class ConcurrencyManagerTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/concurrency_manager")
    @simple_db = SimpleDB.new("./tmp/concurrency_manager", 100, 8)
    # @log_manager = @simple_db.log_manager
  end

  def teardown
    Timecop.return
  end

  def test_lock_table
    concurrency_manager1 = ConcurrencyManager.new
    concurrency_manager2 = ConcurrencyManager.new
    block_id1 = BlockId.new("test1", 0)
    block_id2 = BlockId.new("test1", 1)
    block_id3 = BlockId.new("test2", 0)

    concurrency_manager1.s_lock(block_id1)
    concurrency_manager1.s_lock(block_id1)
    concurrency_manager1.s_lock(block_id2)
    concurrency_manager1.x_lock(block_id3)

    concurrency_manager2.s_lock(block_id1)

    # concurrency_manager の lock 状況を見る
    concurrency_manager_locks1 = concurrency_manager1.instance_variable_get(:@locks)
    concurrency_manager_locks2 = concurrency_manager2.instance_variable_get(:@locks)

    assert_equal concurrency_manager_locks1[block_id1], "S"
    assert_equal concurrency_manager_locks1[block_id2], "S"
    assert_equal concurrency_manager_locks1[block_id3], "X"
    assert_equal concurrency_manager_locks1.size, 3

    assert_equal concurrency_manager_locks2[block_id1], "S"
    assert_equal concurrency_manager_locks2.size, 1

    # locks_tables の lock 状況を見る
    locks_tables = ConcurrencyManager.lock_table

    assert_equal locks_tables.send(:get_lock_value, block_id1), 2
    assert_equal locks_tables.send(:get_lock_value, block_id2), 1
    assert_equal locks_tables.send(:get_lock_value, block_id3), -1

    # release をした後の lock 状況を見る

    concurrency_manager1.release
    locks_after_release1 = concurrency_manager1.instance_variable_get(:@locks)
    assert_equal locks_after_release1.size, 0
    assert_equal locks_tables.send(:get_lock_value, block_id1), 1
    assert_equal locks_tables.send(:get_lock_value, block_id2), 0
    assert_equal locks_tables.send(:get_lock_value, block_id3), 0

    concurrency_manager2.release
    locks_after_release2 = concurrency_manager2.instance_variable_get(:@locks)
    assert_equal locks_after_release2.size, 0
    assert_equal locks_tables.send(:get_lock_value, block_id1), 0
    assert_equal locks_tables.send(:get_lock_value, block_id2), 0
    assert_equal locks_tables.send(:get_lock_value, block_id3), 0
  end

  def test_concurrency
    concurrency_manager1 = ConcurrencyManager.new
    concurrency_manager2 = ConcurrencyManager.new

    block_id1 = BlockId.new("test1", 0)

    threads = []
    threads.push(Thread.new do
      concurrency_manager1.s_lock(block_id1)
    end)
    threads.push(Thread.new do
      sleep(1)
      concurrency_manager2.x_lock(block_id1)
    end)

    concurrency_manager1.release

    threads.each { |t| t.join }

    locks = concurrency_manager2.instance_variable_get(:@locks)
    assert_equal locks[block_id1], "X"
  end
end
