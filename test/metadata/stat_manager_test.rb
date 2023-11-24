# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class StatManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/stat_manager")
    @simple_db = SimpleDB.new("./tmp/stat_manager", 2000, 8)
  end

  def teardown
    # Do nothing
  end

  def test_stat_manager
    transaction = @simple_db.new_transaction
    table_manager = TableManager.new(true, transaction)
    StatManager.new(table_manager, transaction)
  end
end
