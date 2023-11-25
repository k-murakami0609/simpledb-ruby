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

  def test_create_view
    create_view_data = Parser.new("CREATE VIEW view1 AS SELECT * FROM table1").create
    if create_view_data.is_a?(CreateViewData)
      assert_equal create_view_data.view_name, "view1"
      assert_equal create_view_data.query_data.field_names, ["*"]
      assert_equal create_view_data.query_data.table_names, ["table1"]
    else
      assert false
    end
  end

  def test_create_index
    create_index_data = Parser.new("CREATE INDEX index1 ON table1 (field1)").create
    if create_index_data.is_a?(CreateIndexData)
      assert_equal create_index_data.index_name, "index1"
      assert_equal create_index_data.table_name, "table1"
      assert_equal create_index_data.field_name, "field1"
    else
      assert false
    end
  end

  def test_insert
    insert = Parser.new("INSERT INTO table1 (field1, field2) VALUES (1, '2')").insert
    assert_equal insert.table_name, "table1"
    assert_equal insert.field_names, %w[field1 field2]
    assert_equal insert.values, [Constant.new(1), Constant.new("'2'")]
  end

  def test_update
    update = Parser.new("UPDATE table1 SET field1 = 1 WHERE field1 = 2").modify
    assert_equal update.table_name, "table1"
    assert_equal update.field_name, "field1"
    assert_equal update.new_value.value, "1"
  end

  def test_delete
    delete = Parser.new("DELETE FROM table1 WHERE field1 = 2 AND field2 = '3'").delete
    assert_equal delete.table_name, "table1"
    assert_equal delete.predicate.terms[0].left_hand_side.value, "field1"
    assert_equal delete.predicate.terms[0].right_hand_side.value, "2"
    assert_equal delete.predicate.terms[1].left_hand_side.value, "field2"
    assert_equal delete.predicate.terms[1].right_hand_side.value, "'3'"
  end
end
