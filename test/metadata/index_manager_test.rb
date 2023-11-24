# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class IndexManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/index_manager")
    @simple_db = SimpleDB.new("./tmp/index_manager", 30, 8)
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test
    skip "Not implemented"
  end
end
