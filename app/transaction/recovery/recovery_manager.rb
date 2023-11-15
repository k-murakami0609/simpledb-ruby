# frozen_string_literal: true

# transaction ごとにインスタンスが生成される
class RecoveryManager
  def initialize(transaction, transaction_number, log_manager, buffer_manager)
    @transaction = transaction
    @transaction_number = transaction_number
    @log_manager = log_manager
    @buffer_manager = buffer_manager

    StartRecord.write_to_log(@log_manager, @transaction_number)
  end

  def commit
    @buffer_manager.flush_all(@transaction_number)
    lsn = CommitRecord.write_to_log(@log_manager, @transaction_number)
    @log_manager.flush(lsn)
  end

  def rollback
    do_rollback

    @buffer_manager.flush_all(@transaction_number)
    lsn = RollbackRecord.write_to_log(@log_manager, @transaction_number)
    @log_manager.flush(lsn)
  end

  def recover
    do_recover

    @buffer_manager.flush_all(@transaction_number)
    lsn = CheckpointRecord.write_to_log(@log_manager)
    @log_manager.flush(lsn)
  end

  def set_int(buffer, offset, new_value)
    old_val = buffer.contents.get_int(offset)
    block_id = buffer.block_id
    SetIntRecord.write_to_log(@log_manager, @transaction_number, block_id, offset, old_val)
  end

  def set_string(buffer, offset, new_value)
    old_val = buffer.contents.get_string(offset)
    block_id = buffer.block_id
    SetStringRecord.write_to_log(@log_manager, @transaction_number, block_id, offset, old_val)
  end

  def do_rollback
    @log_manager.iterator do |record_bytes|
      record = LogRecord.create_log_record(record_bytes)
      if record.transaction_number != @transaction_number
        next
      end

      if record.type == :start
        break
      end

      record.undo(@transaction)
    end
  end

  def do_recover
    # TODO: Set のほうが早いかも？
    finished_transactions = []
    @log_manager.iterator do |record_bytes|
      record = LogRecord.create_log_record(record_bytes)
      if record.type == :checkpoint
        break
      end

      case record.type
      when :commit, :rollback
        finished_transactions << record.transaction_number
      else
        next if finished_transactions.include?(record.transaction_number)
        record.redo(@transaction)
      end
    end
  end
end
