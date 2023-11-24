# frozen_string_literal: true

require "logger"

class LoggerManager
  @@logger = Logger.new(Object::STDOUT)
  @@logger.level = (ENV["LOG_LEVEL"] || Logger::WARN)

  def self.logger
    # Return the value of this variable
    @@logger
  end

  def initialize
  end

  def self.set_level(level)
    @@logger.level = level
  end
end
