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

      # Snorby collection options.
      @@config_file = File.join(@@path, 'options.yml')

      # log directory
      @@logs = File.join(@@path, 'logs')
      
      # Pid directory
      @@pids = File.join(@@path, 'pids')

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
        if File.exists?(@@config_file)
          @@config = YAML.load_file(@@config_file) if File.readable?(@@config_file)
        else
           logger.fail("Please run `snorby-collect -c` to create a configuration file.")
           logger.fail("All configurations must be set for operations to complete successfully.")
           logger.info("You can run `snorby-collect -c` at any time to edit your configuration.")
          exit -1
        end
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
