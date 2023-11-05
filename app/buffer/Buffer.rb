# frozen_string_literal: true

require_relative '../file/Page'

class Buffer
  attr_accessor :contents, :blk, :pins, :txnum, :lsn

  def initialize(fm, lm)
    @fm = fm
    @lm = lm
    @contents = Page.new(fm.block_size) # assuming a Page class is defined with a method block_size
    @blk = nil
    @pins = 0
    @txnum = -1
    @lsn = -1
  end

  def block
    @blk
  end

  def set_modified(txnum, lsn)
    @txnum = txnum
    @lsn = lsn if lsn >= 0
  end

  def pinned?
    @pins.positive?
  end

  def modifying_tx
    @txnum
  end

  def assign_to_block(b)
    flush
    @blk = b
    @fm.read(@blk, @contents)
    @pins = 0
  end

  def flush
    return unless @txnum >= 0

    @lm.flush(@lsn)
    @fm.write(@blk, @contents)
    @txnum = -1
  end

  def pin
    @pins += 1
  end

  def unpin
    @pins -= 1
  end
end
