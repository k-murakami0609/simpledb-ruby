# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class IndexManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/index_manager")
    @simple_db = SimpleDB.new("./tmp/index_manager", 2000, 8)
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_index_manager
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(true, transaction)
    schema = Schema.new
    schema.add_int_field("field1")
    metadata_manager.create_table("table1", schema, transaction)
    metadata_manager.create_index("index1", "table1", "field1", transaction)
    index_info = metadata_manager.get_index_info("table1", transaction)

    assert_equal index_info["field1"].field_name, "field1"
    assert_equal index_info["field1"].index_name, "index1"

    transaction.commit
  end
end
