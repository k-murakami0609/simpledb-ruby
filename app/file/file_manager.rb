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
class FileManager
  attr_reader :block_size, :is_new

  def initialize(db_directory, block_size)
    @db_directory = db_directory
    @block_size = block_size
    @is_new = !Dir.exist?(db_directory)

    # create the directory if the database is new
    FileUtils.mkdir_p(db_directory) if @is_new

    # remove any leftover temporary tables
    Dir.each_child(db_directory) do |file_name|
      File.delete(File.join(db_directory, file_name)) if file_name.start_with?("temp")
    end

    @open_files = {}
  end

  def read(block_id, page)
    f = get_file(block_id.file_name)
    f.seek(block_id.block_number * @block_size)
    f.read(page.contents.size, page.contents)
  rescue => e
    raise "cannot read block #{block_id}: #{e.message}"
  end

  def write(block_id, page)
    f = get_file(block_id.file_name)
    f.seek(block_id.block_number * @block_size)
    f.write(page.contents)
  rescue => e
    raise "cannot write block #{block_id}: #{e.message}"
  end

  def append(file_name)
    new_block_num = length(file_name)
    block_id = BlockId.new(file_name, new_block_num)
    begin
      f = get_file(block_id.file_name)
      f.seek(block_id.block_number * @block_size)
      f.write("\0" * @block_size)
    rescue => e
      raise "cannot append block #{block_id}: #{e.message}"
    end
    block_id
  end

  def length(file_name)
    f = get_file(file_name)
    f.size / @block_size
  rescue => e
    raise "cannot access #{file_name}: #{e.message}"
  end

  private

  def get_file(file_name)
    f = @open_files[file_name]
    unless f
      db_table = File.join(@db_directory, file_name)
      f = File.new(db_table, "w+b")
      @open_files[file_name] = f
    end
    f
  end
end
