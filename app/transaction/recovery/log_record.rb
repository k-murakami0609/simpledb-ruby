# frozen_string_literal: true

require_relative "set_int_record"
require_relative "set_string_record"
require_relative "rollback_record"
require_relative "checkpoint_record"
require_relative "commit_record"
require_relative "start_record"
require_relative "operation_code"

class LogRecord
  def undo(transaction)
  end

  def self.create_log_record(bytes)
    page = Page.new(bytes)

    record_class = {
      OperationCode::CHECKPOINT => CheckpointRecord,
      OperationCode::START => StartRecord,
      OperationCode::COMMIT => CommitRecord,
      OperationCode::ROLLBACK => RollbackRecord,
      OperationCode::SET_INT => SetIntRecord,
      OperationCode::SET_STRING => SetStringRecord
    }[LogRecord.get_operation_code(page)]

    record_class&.new(page)
  end

  def self.get_operation_code(page)
    page.get_int(0)
  end
end
