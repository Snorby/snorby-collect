require 'snorby/collect/config'
require 'snorby/collect/daemon'
require 'snorby/collect/database'
require 'snorby/collect/helpers'
require 'snorby/collect/logger'
require 'optparse'

module Snorby
  module Collect

    class CLI

      def initialize(*args)
        # CLI arguments
        @args = args
        
        # Run as daemon
        @daemon = false
        
        # Daemon arguments
        @daemon_args = nil
        
        # Run snorby-collect
        @run = false
        
        # Log level
        @verbose = :verbose
        Snorby::Collect.logger = Logger.new(@verbose)
        
        optparse(@args)
      end

      def CLI.start
        self.new(*ARGV)
      end

      protected

        def optparse(*args)
          @opts = OptionParser.new

          @opts.program_name = "snorby-collect"
          @opts.banner = "Snorby Collection Agent v#{Snorby::Collect::VERSION}\n\n"
          @opts.separator "usage: snorby-collect --config PATH --[run/daemon <command>]"

          @opts.on('-r', '--run', 'Start Snorby-Collect without daemonizing the process.') do |run|
            @run = true
          end

          @opts.on('-d', '--daemon COMMAND', 'Run as daemon. Example -d [start,stop,status,restart]') do |daemon_args|
            @daemon = true
            @daemon_args = daemon_args
          end

          @opts.on('-c', '--config PATH', 'Snorby agent configuration file.') do |config|
            @configuration = Config.open(config)
          end

          @opts.on('-q', '--quiet', 'Silence all logging.') do |verbose|
            @verbose = :none
          end

          @opts.on('--debug', 'Debug logging.') do |debug|
            @verbose = :debug
          end

          @opts.on('-v', '--version', 'Version Information') do |version|
            puts "Snorby Collection Agent\nVersion: v#{Snorby::Collect::VERSION}"
            exit -1
          end

          begin
            
            # Build default configuration file
            # and directory structure.
            Config.build_defaults
            
            usage if @args.empty?
            
            @opts.parse!(@args)

            unless @configuration
              usage('You must supply a configuration file.')
            end

            if Config.configured?
              Snorby::Collect.logger = Logger.new(@verbose)
              if @run || @daemon
                if @daemon
                  Daemon.spawn!(
                    {
                      :application => "Snorby Collection Agent v#{Snorby::Collect::VERSION}",
                      :log_file => File.join(Config.logs, "#{Config.logname}.log"),
                      :pid_file => File.join(Config.pids, "#{Config.logname}.pid"),
                      :sync_log => true,
                      :working_dir => Config.path
                    },
                    [@daemon_args, @verbose]
                  )
                else
                  @collect = Collector.new
                  @collect.setup
                  @collect.start
                end

              end
            end
          rescue Interrupt
            Snorby::Collect.logger.warn('Shutting down...')
            exit -1
          rescue RuntimeError => e
            Snorby::Collect.logger.fail(e.message)
            exit -1
          rescue OptionParser::MissingArgument => e
            Snorby::Collect.logger.fail(e.message)
            usage
          rescue OptionParser::InvalidOption => e
            Snorby::Collect.logger.fail(e.message)
            usage
          rescue => e
            Snorby::Collect.logger.fail(e.message)
            exit -1
          end
        end

        def usage(error=nil)
          Snorby::Collect.logger.warn(error) if error
          puts "\n#{@opts}\n"
          exit -1
        end
    end
  end
end
