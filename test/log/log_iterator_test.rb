# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../../app/server/SimpleDB'

class LogIteratorTest < Minitest::Test
  def setup
    FileUtils.rm_rf('./tmp/log_iterator')
    @simple_db = SimpleDB.new('./tmp/log_iterator', 30, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_iterator
    6.times do |i|
      @log_manager.append([i, 2, 3, 4])
    end

    iter = @log_manager.iterator

    assert_next_bytes(iter, [5, 2, 3, 4], 1)
    assert_next_bytes(iter, [4, 2, 3, 4], 1)
    assert_next_bytes(iter, [3, 2, 3, 4], 1)
    assert_next_bytes(iter, [2, 2, 3, 4], 0)
    assert_next_bytes(iter, [1, 2, 3, 4], 0)
    assert_next_bytes(iter, [0, 2, 3, 4], 0)

    assert_equal(false, iter.has_next?)
  end

  def assert_next_bytes(iter, expected_bytes, expected_block_number)
    bytes = iter.next
    assert_equal expected_bytes, bytes
    assert_equal expected_block_number, iter.blk.blknum
  end
end
