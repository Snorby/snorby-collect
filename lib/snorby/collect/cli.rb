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
          @opts.separator "usage: snorby-collect [OPTIONS]"

          @opts.on('-r', '--run', 'Start Snorby-Collect without daemonizing the process.') do |run|
            @run = true
          end

          @opts.on('-d', '--daemon COMMAND', 'Run as daemon. Example -d [start,stop,status,restart]') do |daemon_args|
            @daemon = true
            @daemon_args = daemon_args
          end

          @opts.on('-c', '--config', 'Edit or Create the Snorby-Collect configuration file.') do |config|
            Config.edit
            exit -1
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
            usage if @args.empty?
            @opts.parse!(@args)
            Snorby::Collect.logger = Logger.new(@verbose)

            if Config.configured?
              Snorby::Collect.logger = Logger.new(@verbose)

              if @run || @daemon
                if @daemon
                  Daemon.spawn!({
                  :application => "Snorby Collection Agent v#{Snorby::Collect::VERSION}",
                  :log_file => File.join(Config.logs, 'collection.log'),
                  :pid_file => File.join(Config.pids, 'collection.pid'),
                  :sync_log => true,
                  :working_dir => Config.path
                  }, [@daemon_args, @verbose])
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

        def usage
          puts "\n#{@opts}\n"
          exit -1
        end

    end

  end
end
