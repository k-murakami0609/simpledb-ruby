# frozen_string_literal: true

require_relative '../file/block_id'
require_relative '../file/page'
require_relative 'log_iterator'
class LogMgr
  attr_accessor :fm, :logfile, :logpage, :currentblk, :latest_lsn, :last_saved_lsn

  INTEGER_SIZE = 4
  def initialize(fm, logfile)
    @fm = fm
    @logfile = logfile
    @logpage = Page.new(fm.block_size)
    log_size = fm.length(logfile)

    @currentblk = if log_size.zero?
                    append_new_block
                  else
                    BlockId.new(logfile, log_size - 1)
                    fm.read(@currentblk, @logpage)
                  end
    @latest_lsn = 0
    @last_saved_lsn = 0
  end

  def flush(lsn = nil)
    return unless lsn.nil? || lsn >= @last_saved_lsn

    @fm.write(@currentblk, @logpage)
    @last_saved_lsn = @latest_lsn
  end

  def iterator
    flush
    LogIterator.new(@fm, @currentblk)
  end

  def append(logrec)
    boundary = @logpage.get_int(0)
    rec_size = logrec.length
    bytes_needed = rec_size + INTEGER_SIZE

    if boundary - bytes_needed < INTEGER_SIZE
      flush
      @currentblk = append_new_block
      boundary = @logpage.get_int(0)
    end

    rec_pos = boundary - bytes_needed
    @logpage.set_bytes(rec_pos, logrec)
    @logpage.set_int(0, rec_pos)
    @latest_lsn += 1
    @latest_lsn
  end

  private

  def append_new_block
    blk = @fm.append(@logfile)
    @logpage.set_int(0, @fm.block_size)
    @fm.write(blk, @logpage)
    blk
  end
end
