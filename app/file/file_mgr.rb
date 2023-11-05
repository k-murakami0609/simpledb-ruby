# frozen_string_literal: true

require "fileutils"
require_relative "block_id"

# 階層構造
# File
# ├───Block
# │   ├───Page
# │   │   ├───Record
# │   │   └───Record
# │   └───Page
# │       └───Record
# └───Block
#     ├───Page
#     │   └───Record
#     └───Page
#         └───Record
class FileMgr
  attr_reader :block_size, :is_new

  def initialize(db_directory, block_size)
    @db_directory = db_directory
    @block_size = block_size
    @is_new = !Dir.exist?(db_directory)

    # create the directory if the database is new
    FileUtils.mkdir_p(db_directory) if @is_new

    # remove any leftover temporary tables
    Dir.each_child(db_directory) do |filename|
      File.delete(File.join(db_directory, filename)) if filename.start_with?("temp")
    end

    @open_files = {}
  end

  def read(block_id, page)
    f = get_file(block_id.filename)
    f.seek(block_id.blknum * @block_size)
    f.read(page.contents.size, page.contents)
  rescue => e
    raise "cannot read block #{block_id}: #{e.message}"
  end

  def write(block_id, page)
    f = get_file(block_id.filename)
    f.seek(block_id.blknum * @block_size)
    f.write(page.contents)
  rescue => e
    raise "cannot write block #{block_id}: #{e.message}"
  end

  def append(filename)
    new_block_num = length(filename)
    block_id = BlockId.new(filename, new_block_num)
    begin
      f = get_file(block_id.filename)
      f.seek(block_id.blknum * @block_size)
      f.write("\0" * @block_size)
    rescue => e
      raise "cannot append block #{block_id}: #{e.message}"
    end
    block_id
  end

  def length(filename)
    f = get_file(filename)
    f.size / @block_size
  rescue => e
    raise "cannot access #{filename}: #{e.message}"
  end

  private

  def get_file(filename)
    f = @open_files[filename]
    unless f
      db_table = File.join(@db_directory, filename)
      f = File.new(db_table, "w+b")
      @open_files[filename] = f
    end
    f
  end
end
