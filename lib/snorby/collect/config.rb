require 'snorby/collect/helpers'

require 'pathname'
require 'env'
require 'yaml'

module Snorby
  module Collect
    module Config
      extend Collect::Helpers

      MANDATORY_CONFIGURATION = [
        [:database, 'You must have a database configured.'],
        [:unified2, 'You must have a unified2 log file specified.'],
        [:classifications, 'You must have a classifications file specified.'],
        [:generators, 'You must have a generators file specified.'],
        [:signatures, 'You must have a signatures file specified.'],
        [:sensor, 'You must configure a sensor.']
      ]

      # The users home directory
      @@home = Env.home

      # Snorby directory
      @@path = File.join(@@home,'.snorby')

      # log directory
      @@logs = File.join(@@path, 'logs')

      # Pid directory
      @@pids = File.join(@@path, 'pids')

      # Default configuration file
      @@config_file = File.join(@@path, 'default.yml')

      def Config.open(path)
        
        unless File.exists?(@@config_file)
          # Build default configuration file
          Generator.configuration_file(@@path, @@config_file)
        end

        if File.exists?(path)

          if File.readable?(path)
            # Snorby collection options.
            @@config_file = File.join(@@path)
          else
            logger.fail("#{path} configuration file not readable")
          end

        else
          logger.fail("#{path} configuration file not found")
        end

      end

      def Config.path
        FileUtils.mkdir_p(@@path)
        @@path
      end

      def Config.sensor
        @@config[:sensor]
      end

      def Config.classifications
        @@config[:classifications]
      end

      def Config.signatures
        @@config[:signatures]
      end

      def Config.generators
        @@config[:generators]
      end

      def Config.unified2
        @@config[:unified2]
      end

      def Config.logs
        FileUtils.mkdir_p(@@logs)
        @@logs
      end

      def Config.pids
        FileUtils.mkdir_p(@@pids)
        @@pids
      end

      def Config.configurations
        @@config = YAML.load_file(@@config_file) if File.readable?(@@config_file)
      end

      def Config.edit
        Generator.configuration_file(@@path, @@config_file)
      end

      def Config.configured?
        Config.configurations

        MANDATORY_CONFIGURATION.each do |option, error|
          unless (@@config.has_key?(option) && @@config[option])
            STDERR.puts "Configuration Error: " + error
            exit 1
          end
        end

        true
      end

      def Config.database
        @@config[:database]
      end

    end

  end
end
