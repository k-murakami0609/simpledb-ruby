# frozen_string_literal: true

module UpdateRecord
  def parse_record(page)
    file_name = page.get_string(8)
    positions = UpdateRecord.calc_positions(file_name)

    block_number = page.get_int(positions[:block_number_position])
    [
      page.get_int(positions[:transaction_number_position]),
      BlockId.new(file_name, block_number),
      page.get_int(positions[:offset_position]),
      page.get_int(positions[:value_position])
    ]
  end

  def self.calc_positions(file_name)
    block_number_position = 8 + Page.max_length(file_name)

    {
      transaction_number_position: 4,
      file_name_position: 8,
      block_number_position: block_number_position,
      offset_position: block_number_position + 4,
      value_position: block_number_position + 8
    }
  end
end
