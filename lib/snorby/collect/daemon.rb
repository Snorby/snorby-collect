require 'daemon_spawn'
require 'snorby/collect/collector'
require 'snorby/collect/helpers'

module Snorby
  module Collect
    class Daemon < DaemonSpawn::Base
      include Collect::Helpers

      def start(args)
        args.is_a?(Array) ? ((args.first == :debug) ? log = :verbose : log = :verbose) : log = :verbose
        Snorby::Collect.logger = Logger.new(log)
        logger.say(:info, "Daemon started successfully. PID: #{self.pid}")
        @collect = Collector.new
        @collect.setup
        @collect.start
      end

      def stop
        logger.say(:info, "Shutting down.")
      end

    end
  end
end
