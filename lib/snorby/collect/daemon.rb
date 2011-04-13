require 'pidly'
require 'snorby/collect/collector'
require 'snorby/collect/helpers'

module Snorby
  module Collect
    
    class Daemon < Pidly::Control
      include Collect::Helpers
      
      before_start do
        Snorby::Collect.logger = Logger.new(:verbose, true)
        logger.say(:info, "\"#{@name}\" started successfully (PID: #{@pid})", @log_file, true)
      end
      
      start do
        @collect = Collector.new
        @collect.setup
        @collect.start
      end

      stop do
        logger.say(:info, "Attempting to stop \"#{@name}\" (PID: #{@pid})", @log_file, true)
      end

      after_stop do
        logger.say(:info, "Successfully stopped \"#{@name}\" (PID: #{@pid})", @log_file, true)
      end
      
      error do
        logger.say(:error, "\"#{@name}\" error (PID: #{@pid})", @log_file)
      end
      
      kill do
        logger.say(:info, "Killing \"#{@name}\" (PID: #{@pid})", @log_file)
      end

    end
    
  end
end
