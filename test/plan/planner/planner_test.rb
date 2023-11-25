# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"

class PlannerTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/planner")
    @simple_db = SimpleDB.new("./tmp/planner", 2000, 8)
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_query_plan
    transaction = @simple_db.new_transaction
    metadata_manager = MetadataManager.new(true, transaction)

    schema = Schema.new
    schema.add_int_field("field1")
    metadata_manager.create_table("table1", schema, transaction)

    planner = Planner.new(BasicQueryPlanner.new(metadata_manager), BasicUpdatePlanner.new(metadata_manager))
    plan = planner.create_query_plan("select field1 from table1 WHERE field1 = '2'", transaction)

    assert_equal plan.schema.field_names, ["field1"]

    transaction.commit
  end
end
