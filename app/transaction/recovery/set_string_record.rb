# frozen_string_literal: true

require_relative "log_record"
require_relative "update_record"
class SetStringRecord
  include UpdateRecord

  attr_reader :transaction_number

  def initialize(page)
    @transaction_number, @block_id, @offset, @value = parse_record(page, ->(page, position) { page.get_string(position) })
    @operation_code = LogRecord::SET_STRING
  end

  def to_s
    "<SET_STRING #{@transaction_number} #{@block_id.file_name} #{@block_id.block_number} #{@offset} #{@value}>"
  end

  def undo(transaction)
    transaction.pin(block_id)
    transaction.set_string(block_id, offset, value, false)
    transaction.unpin(block_id)
  end

  # operation_code: 4 bytes
  # transaction_number: 4 bytes
  # file_name: N bytes(4 bytes for length, N bytes for string)
  # block_number: 4 bytes
  # offset: 4 bytes
  # value: 4 bytes
  def self.write_to_log(log_manager, transaction_number, block_id, offset, value)
    positions = UpdateRecord.calc_positions(block_id.file_name)
    record_length = positions[:value_position] + Page.max_length(value)
    page = Page.new(record_length)

    page.set_int(0, LogRecord::SET_STRING)
    page.set_int(positions[:transaction_number_position], transaction_number)
    page.set_string(positions[:file_name_position], block_id.file_name)
    page.set_int(positions[:block_number_position], block_id.block_number)
    page.set_int(positions[:offset_position], offset)
    page.set_string(positions[:value_position], value)

    log_manager.append(page.contents.bytes)
  end
end