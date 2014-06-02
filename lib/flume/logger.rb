module Flume
  class Logger < ::Logger
    extend Forwardable

    attr_reader :logdev
    def_delegators :logdev, :redis, :redis=
    def_delegators :logdev, :list,  :list=
    def_delegators :logdev, :cap,   :cap=
    def_delegators :logdev, :step,  :step=
    def_delegators :logdev, :cycle, :cycle=
    def_delegators :logdev, :tail,  :truncate, :size

    def initialize(*args, &block)
      super(STDERR)
      @logdev = LogDevice.new(*args, &block)
    end
  end
end

