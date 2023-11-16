# frozen_string_literal: true

class RollbackRecord
  attr_reader :transaction_number, :operation_code
  def initialize(page)
    @transaction_number = page.get_int(4)
    @operation_code = OperationCode::ROLLBACK
  end

  def to_s
    "<ROLLBACK #{@transaction_number}>"
  end

  def self.write_to_log(log_manager, transaction_number)
    page = Page.new(8)
    page.set_int(0, OperationCode::ROLLBACK)
    page.set_int(4, transaction_number)

    log_manager.append(page.contents.bytes)
  end
end
