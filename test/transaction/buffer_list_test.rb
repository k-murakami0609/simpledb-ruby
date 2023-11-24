# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class BufferListTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/buffer_list")
    @simple_db = SimpleDB.new("./tmp/buffer_list", 2000, 8)
  end

  def teardown
    # Do nothing
  end

  def test_buffer_list
    buffer_list = BufferList.new(@simple_db.buffer_manager)
    block1 = BlockId.new("buffer_list_test1", 0)
    block2 = BlockId.new("buffer_list_test1", 1)
    buffer_list.pin(block1)
    buffer_list.pin(block1)
    buffer_list.pin(block2)

    assert_equal buffer_list.get_buffer(block1)&.block_id, block1
    assert_equal buffer_list.get_buffer(block2)&.block_id, block2

    buffer_list.unpin(block2)
    assert_nil buffer_list.get_buffer(block2)

    buffer_list.unpin(block1)
    assert_equal buffer_list.get_buffer(block1)&.block_id, block1

    buffer_list.unpin(block1)
    assert_nil buffer_list.get_buffer(block1)
  end
end
