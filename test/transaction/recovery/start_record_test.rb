# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/server/simple_db"

class StartRecordTest < Minitest::Test
  def setup
    # Do nothing
    FileUtils.rm_rf("./tmp/start_record")
    @simple_db = SimpleDB.new("./tmp/start_record", 100, 8)
    @log_manager = @simple_db.log_manager
  end

  def teardown
    # Do nothing
  end

  def test_start_record
    StartRecord.write_to_log(@log_manager, 1)
    iter = @log_manager.iterator
    record = LogRecord.create_log_record(iter.next)

    assert_equal record.to_s, "<START 1>"
  end
end
