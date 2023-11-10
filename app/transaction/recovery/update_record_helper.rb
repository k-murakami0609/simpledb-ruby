# frozen_string_literal: true

class UpdateRecordHelper
  def self.get_file_name(page)
    page.get_string(8)
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
