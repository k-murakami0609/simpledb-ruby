# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"
require_relative "../../../app/transaction/recovery/set_int_record"

class SetIntRecordTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/set_int_record")
    @simple_db = SimpleDB.new("./tmp/set_int_record", 100, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_iterator
    SetIntRecord.write_to_log(@log_manager, 1, BlockId.new("aaa", 10), 3, 10000)
    iter = @log_manager.iterator
    record = LogRecord.create_log_record(iter.next)

    assert_equal record.to_s, "<SET_INT 1 aaa 10 3 10000>"
  end
end
