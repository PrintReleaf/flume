module Flume
  class LogDevice
    lazy_accessor :redis
    lazy_accessor :cap
    lazy_accessor :step
    lazy_accessor :cycle
    lazy_accessor :list

    def initialize(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}

      @config = OpenStruct.new(options)
      block.call(@config) if block

      @redis = @config[:redis] || proc { Redis.new }
      @cap   = @config[:cap]   || (2 ** 16)
      @step  = @config[:step]  || 0
      @cycle = @config[:cycle] || (2 ** 8)
      @list  = @config[:list]  || 'flume:log'
    end

    def write(message)
      begin
        redis.lpush(list, message)
      rescue Object => e
        error = "#{ e.message } (#{ e.class })\n#{ Array(e.backtrace).join(10.chr) }"
        STDERR.puts(error)
        STDERR.puts(message)
      end
    ensure
      if (step % cycle).zero?
        truncate(cap) rescue nil
      end
      self.step = (step + 1) % cycle
    end

    def close
      redis.quit rescue nil
    end

    def tail(n = 1024)
      redis.lrange(list, 0, n - 1).reverse
    end

    def truncate(n)
      redis.ltrim(list, 0, n - 1)
    end

    def size
      redis.llen(list)
    end
  end
end

