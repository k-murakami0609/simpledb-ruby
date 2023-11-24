# frozen_string_literal: true

require "logger"

class LoggerManager
  @@logger = Logger.new($stdout)
  @@logger.level = (ENV["LOG_LEVEL"] || Logger::WARN)

  def self.logger
    # Return the value of this variable
    @@logger
  end

  def self.set_level(level)
    @@logger.level = level
  end
end
