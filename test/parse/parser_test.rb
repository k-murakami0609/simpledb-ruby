# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class ParserTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/parser")
    @simple_db = SimpleDB.new("./tmp/parser", 2000, 8)
  end

  def teardown
    # Do nothing
  end

  def test_select
    query_data = Parser.new("select * from table1, table2 WHERE field1 = 2 AND field2 = '3'").query
    assert_equal query_data.field_names, ["*"]
    assert_equal query_data.table_names, %w[table1 table2]
    assert_equal query_data.predicate.terms[0].left_hand_side.value, "field1"
    assert_equal query_data.predicate.terms[0].right_hand_side.value, "2"
    assert_equal query_data.predicate.terms[1].left_hand_side.value, "field2"
    assert_equal query_data.predicate.terms[1].right_hand_side.value, "'3'"
  end

  def test_create_table
    create_table_data = Parser.new("CREATE TABLE table1 (field1 int, field2 varchar(10))").create
    if create_table_data.is_a?(CreateTableData)
      assert_equal create_table_data.table_name, "table1"
      assert_equal create_table_data.schema.field_names, %w[field1 field2]
      assert_equal create_table_data.schema.type("field1"), Schema::FieldInfo::Type::INTEGER
      assert_equal create_table_data.schema.type("field2"), Schema::FieldInfo::Type::VARCHAR
      assert_equal create_table_data.schema.length("field2"), 10
    else
      assert false
    end
  end
end
