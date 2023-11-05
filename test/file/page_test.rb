# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../app/file/page"

class PageTest < Minitest::Test
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_get_and_set_int
    page = Page.new(100)
    page.set_int(0, 100)
    page.set_int(4, 200)
    page.set_int(8, 300)

    assert_equal 100, page.get_int(0)
    assert_equal 200, page.get_int(4)
    assert_equal 300, page.get_int(8)
  end

  def test_get_and_set_string
    page = Page.new(100)
    offset = 0

    test_strings = ["hello", "🀄🀄🀄", "ruby は便利"]

    test_strings.each do |str|
      page.set_string(offset, str)
      offset += Page.max_length(str)
    end

    offset = 0
    test_strings.each do |str|
      assert_equal str, page.get_string(offset)
      offset += Page.max_length(str)
    end
  end

  def test_get_and_set_bytes
    page = Page.new(100)
    offset = 0

    test_bytes_arrays = [
      [0, 1, 2, 3, 4, 5, 6],
      [6, 7, 8, 9],
      [0x23, 0x44]
    ]

    test_bytes_arrays.each do |bytes_array|
      page.set_bytes(offset, bytes_array)
      offset += Page.max_length(bytes_array)
    end

    offset = 0
    test_bytes_arrays.each do |bytes_array|
      assert_equal bytes_array, page.get_bytes(offset)
      offset += Page.max_length(bytes_array)
    end
  end
end
