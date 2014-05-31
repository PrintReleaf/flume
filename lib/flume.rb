require "flume/version"
require "flume/logger"

module Flume
  def self.logger(*args, &block)
    Logger.new(*args, &block)
  end
end

