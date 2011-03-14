require 'datamapper'
require 'snorby/collect/helpers'
require 'snorby/collect/model'

module Snorby
  module Collect
    module Database
      extend Collect::Helpers

      SUPPORTED_ADAPTERS = [
        'mysql',
        'sqlite',
        'sqlite::memory:',
        'postgres'
      ]

      def Database.connect(options={})
        logger.say(:info, "Initializing database connection.")

        if options.has_key?(:adapter)

          if SUPPORTED_ADAPTERS.include?(options[:adapter])

            begin
              require "dm-#{options[:adapter]}-adapter"
            rescue LoadError => e
              logger.fail(e.message)
              logger.fail("Run `gem install dm-#{options[:adapter]}-adapter` to install dm-#{options[:adapter]}-adapter.")
              exit -1
            end

          else
            logger.fail("ERROR: #{options[:adapter]} is not a supported database adapter.")
            logger.fail("Supported Adapters: #{SUPPORTED_ADAPTERS.join(', ')}")
            exit -1
          end

        else
          logger.fail("ERROR: The database adapter is not configured.")
          logger.fail("Please make sure your configurations are correct.")

          exit -1
        end

        begin
          DataMapper::Logger.new(STDOUT, :debug) if logger.debug?
          DataMapper.setup(:default, options)
          DataMapper.finalize
          DataMapper.auto_upgrade!

          logger.say(:info, 'Connected to database successfully.')
        rescue DataObjects::ConnectionError => e

          logger.fail(e.message)
          
          exit -1
        end
      end

    end
  end
end
