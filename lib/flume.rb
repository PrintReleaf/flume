require 'logger'
require 'ostruct'
require 'redis'
require 'laissez'

require "flume/version"
require "flume/log_device"
require "flume/logger"

module Flume
  def self.logger(*args, &block)
    Logger.new(*args, &block)
  end
end

