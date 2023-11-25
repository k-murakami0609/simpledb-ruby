# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class ViewManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/view_manager")
    @simple_db = SimpleDB.new("./tmp/view_manager", 2000, 8)
  end

  def teardown
    # Do nothing
  end

  def test_view_manager
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(true, transaction)

    metadata_manager.create_table("table1", Schema.new, transaction)
    metadata_manager.create_view("view1", "select * from table1", transaction)
    view = metadata_manager.get_view_definition("view1", transaction)

    assert_equal view, "select * from table1"
    transaction.commit
  end
end
