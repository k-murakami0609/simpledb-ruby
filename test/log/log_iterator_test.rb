# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class LogIteratorTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/log_iterator")
    @simple_db = SimpleDB.new("./tmp/log_iterator", 200, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_iterator
    6.times do |i|
      @log_manager.append([i, (2..100).to_a].flatten)
    end

    iter = @log_manager.iterator

    assert_next_bytes(iter, [5, (2..100).to_a].flatten, 48)
    assert_next_bytes(iter, [4, (2..100).to_a].flatten, 47)
    assert_next_bytes(iter, [3, (2..100).to_a].flatten, 46)
    assert_next_bytes(iter, [2, (2..100).to_a].flatten, 45)
    assert_next_bytes(iter, [1, (2..100).to_a].flatten, 44)
    assert_next_bytes(iter, [0, (2..100).to_a].flatten, 43)

    assert_equal(true, iter.next?)
  end

  def assert_next_bytes(iter, expected_bytes, expected_block_number)
    bytes = iter.next
    assert_equal expected_bytes, bytes
    assert_equal expected_block_number, iter.block_id.block_number
  end
end
