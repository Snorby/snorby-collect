require 'snorby/collect/database'
require 'unified2'

module Snorby
  module Collect
    class Collector
      include Collect::Model
      include Collect::Helpers

      attr_accessor :sensor

      def initialize
        Database.connect(Config.database)

        logger.say(:info, 'Loading configurations into memory.')

        Unified2.configuration do
          sensor :interface => Config.interface,
            :name => Config.name, :checksum => Config.checksum

          load :classifications, Config.classifications
          load :generators, Config.generators
          load :signatures, Config.signatures
        end
      end

      def setup
        logger.say(:info, 'Looking for sensor.')

        @sensor, @host = Sensor.find(Unified2.sensor)
        Unified2.sensor.id = @sensor.id

        logger.say(:info, "Found: \"#{@sensor.name}\" (#{@sensor.interface}@#{@sensor.host.hostname})")
      end

      def start
        begin
          logger.say(:info, "Monitoring unified2 for data to process.")
          Unified2.watch(Config.unified2, @sensor.last_event_id ? @sensor.last_event_id + 1 : :first) do |event|
            next if event.signature.blank?
            
            puts event if logger.debug?
            
            Signature.first_or_create({ :name => event.signature.name }, {
              :signature_id => event.signature.id,
              :generator_id => event.signature.generator,
              :name => event.signature.name,
              :revision => event.signature.revision
            })
            
            Classification.first_or_create({ :short => event.classification.short }, {
              :classification_id => event.classification.id,
              :name => event.classification.name,
              :short => event.classification.short,
              :severity_id => event.classification.severity
            })

            insert_event = Event.new({
                                       :event_id => event.id,
                                       :checksum => event.checksum,
                                       :created_at => event.timestamp,
                                       :sensor_id => event.sensor.id,
                                       :host_id => @host.id,
                                       :source_ip => event.source_ip,
                                       :source_port => event.source_port,
                                       :destination_ip => event.destination_ip,
                                       :destination_port => event.destination_port,
                                       :severity_id => event.severity,
                                       :protocol => event.protocol,
                                       :link_type => event.payload.linktype,
                                       :packet_length => event.payload.length,
                                       :packet => event.payload.hex,
                                       :classification_id => event.classification.id,
                                       :signature_id => event.signature.id,
                                       :severity_id => event.severity
            })

            if insert_event.save
              insert_event.update_sensor
            else
              logger.say(:fail, "Error: #{insert_event.errors}")
            end

          end
        rescue Unified2::FileNotFound => e
          Snorby::Collect.logger.fail(e.message)
          @sensor.destroy
          exit -1
        rescue DataObjects::SyntaxError => e
          Snorby::Collect.logger.fail(e.message)
        rescue => e
          Snorby::Collect.logger.fail(e.message)
        end
      end

    end
  end
end
