# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"

class PlannerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/planner")
    @simple_db = SimpleDB.new("./tmp/planner", 2000, 8)
    # Do nothing
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(true, transaction)

    schema = Schema.new
    schema.add_int_field("field1")
    schema.add_string_field("field2", 200)
    metadata_manager.create_table("table1", schema, transaction)

    transaction.commit
  end

  def teardown
    # Do nothing
  end

  def test_query_plan
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(false, transaction)

    planner = Planner.new(BasicQueryPlanner.new(metadata_manager), BasicUpdatePlanner.new(metadata_manager))
    plan = planner.create_query_plan("select field1 from table1 WHERE field1 = '2'", transaction)

    assert_equal plan.schema.field_names, ["field1"]

    transaction.commit
  end

  def test_insert_update_delete
    # LoggerManager.set_level(Logger::DEBUG)
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(false, transaction)

    planner = Planner.new(BasicQueryPlanner.new(metadata_manager), BasicUpdatePlanner.new(metadata_manager))
    result = planner.execute_update("insert into table1 (field1, field2) values (200, 'test')", transaction)

    assert_equal result, 1

    plan = planner.create_query_plan("select field1, field2 from table1", transaction)
    scan = plan.open
    scan.before_first
    while scan.next?
      assert_equal scan.get_int("field1"), 200
      assert_equal scan.get_string("field2"), "'test'"
    end

    result = planner.execute_update("UPDATE table1 SET field1 = 300", transaction)
    assert_equal result, 1

    plan = planner.create_query_plan("select field1, field2 from table1", transaction)
    scan = plan.open
    scan.before_first
    while scan.next?
      assert_equal scan.get_int("field1"), 300
      assert_equal scan.get_string("field2"), "'test'"
    end

    result = planner.execute_update("DELETE FROM table1", transaction)
    assert_equal result, 1
    assert_equal scan.next?, false

    transaction.commit
  end
end
