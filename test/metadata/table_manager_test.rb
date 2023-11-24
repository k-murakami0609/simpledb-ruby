# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class TableManagerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/table_manager")
    @simple_db = SimpleDB.new("./tmp/table_manager", 2000, 8)
  end

  def teardown
    # Do nothing
  end

  def test_table_manager
    transaction = @simple_db.new_transaction
    table_manager = TableManager.new(true, transaction)

    schema = Schema.new
    schema.add_string_field("name", 10)
    schema.add_int_field("age")
    table_manager.create_table("table1", schema, transaction)

    layout = table_manager.get_layout("table1", transaction)
    assert_equal layout.schema.field_names, %w[name age]
    assert_equal layout.schema.type("name"), Schema::FieldInfo::Type::VARCHAR
    assert_equal layout.schema.type("age"), Schema::FieldInfo::Type::INTEGER
    assert_equal layout.offset("name"), 4
    assert_equal layout.offset("age"), 14
    transaction.commit
  end
end
