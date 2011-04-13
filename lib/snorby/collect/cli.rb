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
        @args = args
        @daemon = false
        @daemon_args = nil
        @run = false
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

          @opts.on('-d', '--daemon COMMAND', 'Run as daemon. Example -d [start,stop,status,restart,kill,clean]') do |daemon_args|
            @daemon = true
            if daemon_args.match(/^(start|stop|status|restart|kill|clean!)$/)
              @daemon_args = daemon_args
            else
              Snorby::Collect.logger.fail("Unknown option for daemon `#{daemon_args}`")
              Snorby::Collect.logger.info("Available options: start, stop, status and restart.")
              usage
            end
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

          #begin
            # Build default configuration file and directory structure.
            Config.build_defaults

            usage if @args.empty?
            @opts.parse!(@args)

            unless @configuration
              Snorby::Collect.logger.fail('You must supply a configuration file.')
              Snorby::Collect.logger.info("Example: snorby-collect --run --config /path/to/config")
              usage
            end

            if Config.configured?

              Snorby::Collect.logger = Logger.new(@verbose)
              if @run || @daemon
                if @daemon
                  collect = Daemon.spawn(
                    :name => Config.name,
                    :path => Config.path,
                    :sync_log => true,
                    :verbose => true
                  )
                  collect.send @daemon_args
                else
                  @collect = Collector.new
                  @collect.setup
                  @collect.start
                end

              end
            end
          # rescue Interrupt
          #   Snorby::Collect.logger.warn('Shutting down...')
          #   exit -1
          # rescue RuntimeError => e
          #   Snorby::Collect.logger.fail(e.message)
          #   exit -1
          # rescue OptionParser::MissingArgument => e
          #   Snorby::Collect.logger.fail(e.message)
          #   usage
          # rescue OptionParser::InvalidOption => e
          #   Snorby::Collect.logger.fail(e.message)
          #   usage
          # rescue => e
          #   Snorby::Collect.logger.fail(e.message)
          #   exit -1
          # end
        end

        def usage(error=nil)
          Snorby::Collect.logger.warn(error) if error
          puts "\n#{@opts}\n"
          exit -1
        end
    end
  end
end
