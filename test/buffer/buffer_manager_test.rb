# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"
require_relative "../../app/file/block_id"
class BufferManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/buffer_manager")
    @simple_db = SimpleDB.new("./tmp/buffer_manager", 400, 3)
    @buffer_manager = @simple_db.buffer_manager
    @file_manager = @simple_db.file_manager
  end

  def teardown
    # Do nothing
  end

  def test_is_work
    buff1 = @buffer_manager.pin(BlockId.new("testfile", 1))
    page1 = buff1.contents
    page1.set_int(0, 9999)
    buff1.set_modified(1, 0) # placeholder values
    @buffer_manager.unpin(buff1)

    @buffer_manager.pin(BlockId.new("testfile", 2))
    @buffer_manager.pin(BlockId.new("testfile", 3))
    @buffer_manager.pin(BlockId.new("testfile", 4))

    @buffer_manager.flush_all(1)

    read_page1 = Page.new(400)
    @file_manager.read(BlockId.new("testfile", 1), read_page1)
    assert_equal 9999, read_page1.get_int(0)
  end
end
