require 'spec_helper'

describe Flume::Logger do
  let(:logger)   { Flume::Logger.new }
  let(:logdev)   { double }
  let(:sentinel) { double }

  before do
    logger.stub(:logdev) { logdev }
  end

  it "delegates #redis to its logdev" do
    logdev.stub(:redis => sentinel)
    expect(logger.redis).to eql sentinel
  end

  it "delegates #redis= to its logdev" do
    expect(logdev).to receive(:redis=).with(sentinel)
    logger.redis = sentinel
  end

  it "delegates #list to its logdev" do
    logdev.stub(:list => sentinel)
    expect(logger.list).to eql sentinel
  end

  it "delegates #list= to its logdev" do
    expect(logdev).to receive(:list=).with(sentinel)
    logger.list = sentinel
  end

  it "delegates #cap to its logdev" do
    logdev.stub(:cap => sentinel)
    expect(logger.cap).to eql sentinel
  end

  it "delegates #cap= to its logdev" do
    expect(logdev).to receive(:cap=).with(sentinel)
    logger.cap = sentinel
  end

  it "delegates #step to its logdev" do
    logdev.stub(:step => sentinel)
    expect(logger.step).to eql sentinel
  end

  it "delegates #step= to its logdev" do
    expect(logdev).to receive(:step=).with(sentinel)
    logger.step = sentinel
  end

  it "delegates #cycle to its logdev" do
    logdev.stub(:cycle => sentinel)
    expect(logger.cycle).to eql sentinel
  end

  it "delegates #cycle= to its logdev" do
    expect(logdev).to receive(:cycle=).with(sentinel)
    logger.cycle = sentinel
  end

  it "delegates #tail to its logdev" do
    logdev.stub(:tail => sentinel)
    expect(logger.tail).to eql sentinel
  end

  it "delegates #truncate to its logdev" do
    logdev.stub(:truncate => sentinel)
    expect(logger.truncate).to eql sentinel
  end

  it "delegates #size to its logdev" do
    logdev.stub(:size => sentinel)
    expect(logger.size).to eql sentinel
  end
end

