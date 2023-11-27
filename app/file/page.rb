# frozen_string_literal: true

require "stringio"

class Page
  CHARSET = Encoding::UTF_8
  BYTES_PER_UNIT = 4

  def initialize(arg)
    case arg
    when Integer # blocksize
      @buffer = StringIO.new("\0" * arg)
    when String # byte array
      @buffer = StringIO.new(arg)
    when Array
      @buffer = StringIO.new("\0" * arg.length)
      @buffer.write(arg.pack("c*"))
    else
      raise ArgumentError, "Expected Integer or String, got #{arg.class}"
    end
  end

  def get_int(offset)
    LoggerManager.logger.debug("Page.get_int: offset=#{offset}")

    @buffer.seek(offset)
    @buffer.read(BYTES_PER_UNIT).unpack1("l>")
  end

  def set_int(offset, n)
    LoggerManager.logger.debug("Page.set_int: offset=#{offset}, n=#{n}")

    @buffer.seek(offset)
    @buffer.write([n].pack("l>"))
  end

  def get_bytes(offset)
    LoggerManager.logger.debug("Page.get_bytes: offset=#{offset}")

    @buffer.seek(offset)
    length = @buffer.read(BYTES_PER_UNIT).unpack1("l>")
    @buffer.read(length).bytes
  end

  def set_bytes(offset, bytes)
    raise ArgumentError, "offset is negative, offset=#{offset}" if offset.negative?
    LoggerManager.logger.debug("Page.set_bytes: offset=#{offset}, bytes=#{bytes}")

    @buffer.seek(offset)
    @buffer.write([bytes.length].pack("l>"))
    @buffer.write(bytes.pack("c*"))
  end

  def get_string(offset)
    LoggerManager.logger.debug("Page.get_bytes: offset=#{offset}")

    get_bytes(offset).pack("c*").force_encoding(CHARSET)
  end

  def set_string(offset, str)
    LoggerManager.logger.debug("Page.set_string: offset=#{offset}, str=#{str}")

    set_bytes(offset, str.encode(CHARSET).bytes)
  end

  def self.max_length(str)
    4 + (str.length * BYTES_PER_UNIT)
  end

  def contents
    @buffer.string
  end
end
