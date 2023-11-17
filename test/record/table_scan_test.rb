# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class TableScanTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/table_scan")
    @simple_db = SimpleDB.new("./tmp/table_scan", 400, 8)
  end

  def teardown
    # Do nothing
  end

  def test_table_scan
    transaction = @simple_db.new_transaction

    schema = Schema.new
    schema.add_int_field("A")
    schema.add_string_field("B", 9)

    layout = Layout.new(schema)
    offset = layout.offset(layout.schema.field_names[0])
    assert_equal layout.schema.field_names[0], "A"
    assert_equal offset, 4

    offset += layout.offset(layout.schema.field_names[1])
    assert_equal layout.schema.field_names[1], "B"
    assert_equal offset, 12

    table_scan = TableScan.new(transaction, "test_table_scan", layout)
    50.times do |i|
      table_scan.insert
      table_scan.set_int("A", i)
      table_scan.set_string("B", "record#{i}")
    end

    table_scan.before_first
    count = 0
    while table_scan.next?
      assert_equal table_scan.get_int("A"), count
      assert_equal table_scan.get_string("B"), "record#{count}"
      count += 1

      if count < 25
        table_scan.delete
      end
    end

    count = 24
    table_scan.before_first
    while table_scan.next?
      assert_equal table_scan.get_int("A"), count
      assert_equal table_scan.get_string("B"), "record#{count}"
      count += 1
    end

    table_scan.close
    transaction.commit
  end
end
