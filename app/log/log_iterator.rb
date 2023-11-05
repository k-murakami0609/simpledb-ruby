# frozen_string_literal: true

require_relative "../file/block_id"

class LogIterator
  include Enumerable

  attr_accessor :blk

  INTEGER_SIZE = 4

  def initialize(file_manager, blk)
    @file_manager = file_manager
    @blk = blk
    @p = Page.new(file_manager.block_size)
    move_to_block(@blk)
  end

  def each
    return enum_for(:each) unless block_given?

    yield self.next while has_next?
  end

  def has_next?
    @currentpos < @file_manager.block_size || @blk.blknum.positive?
  end

  def next
    if @currentpos == @file_manager.block_size
      @blk = BlockId.new(@blk.filename, @blk.blknum - 1)
      move_to_block(@blk)
    end

    rec = @p.get_bytes(@currentpos)
    @currentpos += INTEGER_SIZE + rec.length
    rec
  end

  private

  def move_to_block(blk)
    @file_manager.read(blk, @p)
    @boundary = @p.get_int(0)
    @currentpos = @boundary
  end
end
