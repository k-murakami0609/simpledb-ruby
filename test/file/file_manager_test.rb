# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../app/file/file_manager"
require_relative "../../app/file/page"
require_relative "../../app/file/block_id"

class FileManagerTest < Minitest::Test
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_can_write_and_read_in_multiple_blocks
    file_manager = FileManager.new("./tmp/file_manager", 100)
    block_id1 = BlockId.new("can_write_and_read_in_multiple_blocks1", 0)
    block_id2 = BlockId.new("can_write_and_read_in_multiple_blocks2", 1)

    write_page1 = Page.new(100)
    write_page2 = Page.new(100)

    write_page1.set_int(0, 100)
    write_page1.set_int(4, 200)
    write_page1.set_int(8, 300)
    write_page1.set_string(12, "🀄🀄🀄")
    write_page2.set_string(0, "hello")

    file_manager.write(block_id1, write_page1)
    file_manager.write(block_id2, write_page2)

    read_page1 = Page.new(100)
    read_page2 = Page.new(100)

    file_manager.read(block_id1, read_page1)
    file_manager.read(block_id2, read_page2)

    assert_equal 200, read_page1.get_int(4)
    assert_equal "🀄🀄🀄", read_page1.get_string(12)
    assert_equal "hello", read_page2.get_string(0)
  end

  def test_counts_blocks
    file_manager = FileManager.new("./tmp/file_manager", 100)

    block_id1 = BlockId.new("count_blocks", 0)
    block_id2 = BlockId.new("count_blocks", 1)
    block_id3 = BlockId.new("count_blocks", 2)

    page = Page.new(100)

    file_manager.write(block_id1, page)
    file_manager.write(block_id2, page)
    file_manager.write(block_id3, page)

    assert_equal file_manager.length("count_blocks"), 3
  end

  def test_append
    file_manager = FileManager.new("./tmp/file_manager", 100)

    file_manager.append("append_new_block")
    file_manager.append("append_new_block")
    file_manager.append("append_new_block")
    file_manager.append("append_new_block")

    assert_equal file_manager.length("append_new_block"), 4
  end
end
