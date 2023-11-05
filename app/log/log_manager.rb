# frozen_string_literal: true

require_relative "../file/block_id"
require_relative "../file/page"
require_relative "log_iterator"
class LogManager
  attr_accessor :file_manager, :logfile, :logpage, :currentblock_id, :latest_lsn, :last_saved_lsn

  INTEGER_SIZE = 4
  def initialize(file_manager, logfile)
    @file_manager = file_manager
    @logfile = logfile
    @logpage = Page.new(file_manager.block_size)
    log_size = file_manager.length(logfile)

    @currentblock_id = if log_size.zero?
      append_new_block
    else
      BlockId.new(logfile, log_size - 1)
      file_manager.read(@currentblock_id, @logpage)
    end
    @latest_lsn = 0
    @last_saved_lsn = 0
  end

  def flush(lsn = nil)
    return unless lsn.nil? || lsn >= @last_saved_lsn

    @file_manager.write(@currentblock_id, @logpage)
    @last_saved_lsn = @latest_lsn
  end

  def iterator
    flush
    LogIterator.new(@file_manager, @currentblock_id)
  end

  def append(logrec)
    boundary = @logpage.get_int(0)
    rec_size = logrec.length
    bytes_needed = rec_size + INTEGER_SIZE

    if boundary - bytes_needed < INTEGER_SIZE
      flush
      @currentblock_id = append_new_block
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
    block_id = @file_manager.append(@logfile)
    @logpage.set_int(0, @file_manager.block_size)
    @file_manager.write(block_id, @logpage)
    block_id
  end
end
