# frozen_string_literal: true

require_relative "set_int_record"
require_relative "set_string_record"

class LogRecord
  CHECKPOINT = 0
  START = 1
  COMMIT = 2
  ROLLBACK = 3
  SET_INT = 4
  SET_STRING = 5

  attr_reader :operation_code

  def undo(transaction)
  end

  def self.create_log_record(bytes)
    page = Page.new(bytes)

    record_class = {
      # CHECKPOINT => CheckpointRecord,
      # START => StartRecord,
      # COMMIT => CommitRecord,
      # ROLLBACK => RollbackRecord,
      SET_INT => SetIntRecord,
      SET_STRING => SetStringRecord
    }[LogRecord.get_operation_code(page)]

    record_class&.new(page)
  end

  def self.get_operation_code(page)
    page.get_int(0)
  end
end
