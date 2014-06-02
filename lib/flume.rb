require 'logger'
require 'ostruct'
require 'redis'
require 'laissez'

require "flume/version"
require "flume/log_device"
require "flume/logger"

module Flume
  def self.logger(*args, &block)
    logger = Logger.new(*args, &block)

    if defined?(::ActiveSupport::TaggedLogging)
      logger = ::ActiveSupport::TaggedLogging.new(logger)
    end

    return logger
  end
end

