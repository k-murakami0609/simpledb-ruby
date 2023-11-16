# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"

class CheckpointRecordTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/checkpoint_record")
    @simple_db = SimpleDB.new("./tmp/checkpoint_record", 100, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_iterator
    CheckpointRecord.write_to_log(@log_manager)
    iter = @log_manager.iterator
    record = LogRecord.create_log_record(iter.next)

    assert_equal record.to_s, "<CHECKPOINT>"
  end
end
