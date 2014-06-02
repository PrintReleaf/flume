require 'spec_helper'
require 'mock_redis'
require 'timecop'

$redis = MockRedis.new

def clear_redis!
  keys = $redis.keys('*')
  $redis.del(*keys) if keys.any?
end

describe Flume, ".logger" do
  before { clear_redis! }
  before { Timecop.freeze(Time.local(2014)) }
  after  { Timecop.return }

  it "returns a new logger" do
    logger = Flume.logger :list => "flume:test:log" do |config|
      config.redis = $redis
      config.cap = proc { 1 > 0 ? 1024 : 2048 }
    end

    logger.unknown "An unknown message that should always be logged."
    logger.fatal   "An unhandleable error that results in a program crash."
    logger.error   "A handleable error condition."
    logger.warn    "A warning."
    logger.info    "Generic (useful) information about system operation."
    logger.debug   "Low-level information for developers."

    logs = logger.tail
    expect(logs[0]).to match /A, \[2014-01-01T00:00:00.000000 #\d+\]   ANY -- : An unknown message that should always be logged./
    expect(logs[1]).to match /F, \[2014-01-01T00:00:00.000000 #\d+\] FATAL -- : An unhandleable error that results in a program crash\./
    expect(logs[2]).to match /E, \[2014-01-01T00:00:00.000000 #\d+\] ERROR -- : A handleable error condition\./
    expect(logs[3]).to match /W, \[2014-01-01T00:00:00.000000 #\d+\]  WARN -- : A warning\./
    expect(logs[4]).to match /I, \[2014-01-01T00:00:00.000000 #\d+\]  INFO -- : Generic \(useful\) information about system operation\./
    expect(logs[5]).to match /D, \[2014-01-01T00:00:00.000000 #\d+\] DEBUG -- : Low-level information for developers\./

    logs = logger.tail(3)
    expect(logs[0]).to match /W, \[2014-01-01T00:00:00.000000 #\d+\]  WARN -- : A warning\./
    expect(logs[1]).to match /I, \[2014-01-01T00:00:00.000000 #\d+\]  INFO -- : Generic \(useful\) information about system operation\./
    expect(logs[2]).to match /D, \[2014-01-01T00:00:00.000000 #\d+\] DEBUG -- : Low-level information for developers\./

    expect(logger.redis).to eql($redis)
    expect(logger.list).to eql("flume:test:log")
    expect(logger.cap).to eql(1024)
    expect(logger.size).to eql(6)

    logger.truncate(3)
    expect(logger.size).to eql(3)
  end
end

