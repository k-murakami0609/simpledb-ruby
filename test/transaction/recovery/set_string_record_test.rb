# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"
require_relative "../../../app/transaction/recovery/set_string_record"

class SetStringRecordTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/set_string_record")
    @simple_db = SimpleDB.new("./tmp/set_string_record", 100, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_iterator
    SetStringRecord.write_to_log(@log_manager, 1, BlockId.new("aaa", 10), 3, "あかさたな")
    iter = @log_manager.iterator
    record = LogRecord.create_log_record(iter.next)

    assert_equal record.to_s, "<SET_STRING 1 aaa 10 3 あかさたな>"
  end
end
