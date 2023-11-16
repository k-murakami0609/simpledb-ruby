# frozen_string_literal: true

class CheckpointRecord
  attr_reader :transaction_number, :operation_code
  def initialize(page)
    @operation_code = OperationCode::CHECKPOINT
    @transaction_number = -1
  end

  def to_s
    "<CHECKPOINT>"
  end

  def self.write_to_log(log_manager)
    page = Page.new(4)
    page.set_int(0, OperationCode::CHECKPOINT)

    log_manager.append(page.contents.bytes)
  end
end
