require 'spec_helper'

describe Flume::LogDevice, ".new" do
  # Sentinel values
  let(:redis) { double }
  let(:cap)   { double }
  let(:step)  { double }
  let(:cycle) { double }
  let(:list)  { double }

  it "has reasonable defaults" do
    Redis.stub(:new) { redis }
    logdev = Flume::LogDevice.new
    expect(logdev.redis).to eql(redis)
    expect(logdev.cap).to   eql(65536)
    expect(logdev.step).to  eql(0)
    expect(logdev.cycle).to eql(256)
    expect(logdev.list).to  eql("flume:log")
  end

  it "can be configured with a hash" do
    logdev = Flume::LogDevice.new(
      :redis => redis,
      :cap   => cap,
      :step  => step,
      :cycle => cycle,
      :list  => list
    )

    expect(logdev.redis).to eql(redis)
    expect(logdev.cap).to   eql(cap)
    expect(logdev.step).to  eql(step)
    expect(logdev.cycle).to eql(cycle)
    expect(logdev.list).to  eql(list)
  end

  it "can be configured with a block" do
    logdev = Flume::LogDevice.new do |config|
      config.redis = redis
      config.cap   = cap
      config.step  = step
      config.cycle = cycle
      config.list  = list
    end

    expect(logdev.redis).to eql(redis)
    expect(logdev.cap).to   eql(cap)
    expect(logdev.step).to  eql(step)
    expect(logdev.cycle).to eql(cycle)
    expect(logdev.list).to  eql(list)
  end

  it "can be configured with both a hash and a block" do
    logdev = Flume::LogDevice.new redis: redis, cap: cap do |config|
      config.step  = step
      config.cycle = cycle
      config.list  = list
    end

    expect(logdev.redis).to eql(redis)
    expect(logdev.cap).to   eql(cap)
    expect(logdev.step).to  eql(step)
    expect(logdev.cycle).to eql(cycle)
    expect(logdev.list).to  eql(list)
  end
end

describe Flume::LogDevice, "#channel" do
  it "returns its pubsub channel" do
    logdev = Flume::LogDevice.new list: "my:list"
    expect(logdev.channel).to eql "flume:my:list"
  end
end

describe Flume::LogDevice, "#write" do
  it "pushes the message onto the redis list" do
    redis = double.as_null_object
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list")
    expect(redis).to receive(:lpush).with("my:list", "hello world")
    logdev.write("hello world")
  end

  it "auto-truncates the list" do
    redis = double.as_null_object
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list", cap: 12, cycle: 4)
    expect(redis).to receive(:ltrim).with("my:list", 0, 11).exactly(8).times
    32.times do
      logdev.write("hello world")
    end
  end

  it "publishes the message to its channel" do
    redis = double.as_null_object
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list")
    expect(redis).to receive(:publish).with("flume:my:list", "my message")
    logdev.write("my message")
  end

  context "when there is an error writing to redis" do
    it "prints the error and the message" do
      redis = double.as_null_object
      redis.stub(:lpush) { raise StandardError }
      logdev = Flume::LogDevice.new(redis: redis)
      expect(STDERR).to receive(:puts).with(/StandardError \(StandardError\)/).once
      expect(STDERR).to receive(:puts).with("this will raise").once
      logdev.write("this will raise")
    end
  end
end

describe Flume::LogDevice, "#close" do
  it "quits redis" do
    redis = double
    logdev = Flume::LogDevice.new(redis: redis)
    expect(redis).to receive(:quit)
    logdev.close
  end
end

describe Flume::LogDevice, "#tail(n)" do
  it "returns the last n items" do
    redis = double
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list")
    redis.stub(:lrange).
          with("my:list", 0, 599).
          and_return(["item1", "item2", "item3"])
    expect(logdev.tail(600)).to eql ["item3", "item2", "item1"]
  end
end

describe Flume::LogDevice, "#truncate(n)" do
  it "truncates the list" do
    redis = double
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list")
    expect(redis).to receive(:ltrim).with("my:list", 0, 99)
    logdev.truncate(100)
  end
end

describe Flume::LogDevice, "#size" do
  it "returns the size of the list" do
    redis = double
    logdev = Flume::LogDevice.new(redis: redis, list: "my:list")
    redis.stub(:llen).
          with("my:list").
          and_return(123456)
    expect(logdev.size).to eql 123456
  end
end


