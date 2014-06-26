require 'spec_helper'

describe Flume, '.logger' do
  it "news up a configured logger and returns it" do
    configuration = lambda {}
    flume_logger = double
    expect(Flume::Logger).to receive(:new).
                             with({ list: "flume:test:log" }, &configuration).
                             and_return(flume_logger)
    logger = Flume.logger(list: "flume:test:log", &configuration)
    expect(logger).to eql flume_logger
  end

  it "wraps it in tagged logging if it exists" do
    flume_logger   = double
    tagged_logging = double
    wrapped_logger = double

    Flume::Logger.stub(:new) { flume_logger }
    stub_const("ActiveSupport::TaggedLogging", tagged_logging)

    tagged_logging.stub(:new).
                   with(flume_logger).
                   and_return(wrapped_logger)

    logger = Flume.logger
    expect(logger).to eql wrapped_logger
  end
end

