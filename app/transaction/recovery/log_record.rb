# frozen_string_literal: true

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
