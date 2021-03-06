module Flume
  class CLI < Thor

    desc "tail LIST", "display the last part of a log"
    option :f, :type => :boolean, :default => false
    option :number, :type => :numeric, :default => 80, :aliases => :n
    def tail(list)
      logger = Flume.logger :list => list
      puts logger.tail(options[:number])

      if options[:f]
        trap(:INT) { puts; exit }
        logger.tailf do |line|
          puts line
        end
      end
    end

    desc "version", "show Flume version and quit"
    def version
      puts "Flume #{Flume::VERSION}"
    end

  end
end
