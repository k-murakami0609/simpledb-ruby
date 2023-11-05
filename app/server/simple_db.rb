# frozen_string_literal: true

require_relative '../file/file_mgr'
require_relative '../log/log_mgr'
require_relative '../buffer/buffer_mgr'
class SimpleDB
  LOG_FILE = 'simpledb.log'

  attr_reader :block_size, :buffer_size, :log_file, :file_manager, :buffer_manager, :log_manager

  def initialize(db_directory_path, block_size, buffer_size)
    @block_size = block_size
    @buffer_size = buffer_size
    @log_file = LOG_FILE

    @file_manager = FileMgr.new(db_directory_path, block_size)
    @log_manager = LogMgr.new(@file_manager, LOG_FILE)
    @buffer_manager = BufferMgr.new(@file_manager, @log_manager, buffer_size)
  end

  # def new_transaction
  #   Transaction.new(file_manager, log_manager, buffer_manager)
  # end
end
