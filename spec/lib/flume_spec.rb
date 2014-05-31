require 'spec_helper'
require 'mock_redis'
require 'timecop'

$redis = MockRedis.new

def clear_redis!
  keys = $redis.keys('*')
  $redis.del(*keys) if keys.any?
end

describe Flume, ".logger" do
  before { Timecop.freeze(Time.local(2014)) }
  after  { Timecop.return }

  before { clear_redis! }
  before do
    Flume::Logger::Formatter.any_instance.stub(:pid) { "12345" }
  end

  it "returns a new logger" do
    logger = Flume.logger do |config|
      config.redis = $redis
      config.list = "flume:test:log"
    end

    logger.unknown "An unknown message that should always be logged."
    logger.fatal   "An unhandleable error that results in a program crash."
    logger.error   "A handleable error condition."
    logger.warn    "A warning."
    logger.info    "Generic (useful) information about system operation."
    logger.debug   "Low-level information for developers."

    expect(logger.tail).to eql([
      "A, [2014-01-01T00:00:00.000000 #12345]   ANY : An unknown message that should always be logged.\n",
      "F, [2014-01-01T00:00:00.000000 #12345] FATAL : An unhandleable error that results in a program crash.\n",
      "E, [2014-01-01T00:00:00.000000 #12345] ERROR : A handleable error condition.\n",
      "W, [2014-01-01T00:00:00.000000 #12345]  WARN : A warning.\n",
      "I, [2014-01-01T00:00:00.000000 #12345]  INFO : Generic (useful) information about system operation.\n",
      "D, [2014-01-01T00:00:00.000000 #12345] DEBUG : Low-level information for developers.\n"
    ])

    expect(logger.tail(2)).to eql([
      "I, [2014-01-01T00:00:00.000000 #12345]  INFO : Generic (useful) information about system operation.\n",
      "D, [2014-01-01T00:00:00.000000 #12345] DEBUG : Low-level information for developers.\n"
    ])

    expect(logger.redis).to eql($redis)
    expect(logger.list).to eql("flume:test:log")
    expect(logger.size).to eql(6)

    logger.truncate(3)
    expect(logger.size).to eql(3)
  end
end

