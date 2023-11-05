# frozen_string_literal: true

require_relative "../file/block_id"

class LogIterator
  include Enumerable

  attr_accessor :block_id

  INTEGER_SIZE = 4

  def initialize(file_manager, block_id)
    @file_manager = file_manager
    @block_id = block_id
    @page = Page.new(file_manager.block_size)
    move_to_block(@block_id)
  end

  def each
    return enum_for(:each) unless block_given?

    yield self.next while has_next?
  end

  def has_next?
    @currentpos < @file_manager.block_size || @block_id.block_number.positive?
  end

  def next
    if @currentpos == @file_manager.block_size
      @block_id = BlockId.new(@block_id.file_name, @block_id.block_number - 1)
      move_to_block(@block_id)
    end

    record = @page.get_bytes(@currentpos)
    @currentpos += INTEGER_SIZE + record.length
    record
  end

  private

  def move_to_block(block_id)
    @file_manager.read(block_id, @page)
    @boundary = @page.get_int(0)
    @currentpos = @boundary
  end
end
