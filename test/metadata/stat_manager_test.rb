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
    stat_manager = StatManager.new(table_manager, transaction)
    table_manager.create_table("table100", Schema.new, transaction)
    stat_info = stat_manager.get_stat_info("table100", table_manager.get_layout("table100", transaction), transaction)

    assert_equal stat_info.num_blocks, 0
    assert_equal stat_info.num_records, 0

    transaction.commit
  end
end
