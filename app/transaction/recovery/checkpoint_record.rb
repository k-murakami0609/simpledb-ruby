# frozen_string_literal: true

require_relative "operation_code"
require_relative "../../file/page"
class CheckpointRecord
  attr_accessor :transaction_number
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
