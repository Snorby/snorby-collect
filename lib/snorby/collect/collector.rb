require 'unified2'
require 'snorby/collect/database'

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
          sensor :interface => Config.sensor[:interface],
            :name => Config.sensor[:name]
            
          load :classifications, Config.classifications
          load :generators, Config.generators
          load :signatures, Config.signatures
        end
      end

      def setup
        logger.say(:info, 'Looking for sensor.')
        @sensor = Sensor.find(Unified2.sensor)
        Unified2.sensor.id = sensor.id
        logger.say(:info, "Found: #{@sensor.hostname}")
        
        [[Classification,:classifications], [Signature, :signatures], [Signature, :generators]].each do |klass, method|
          unless sensor.send(:"#{method}_md5") == Unified2.send(method).send(:md5)
            logger.say(:info, "Database Import: #{method}.")
            klass.send(:import,  { method => Unified2.send(method).send(:data)})
            sensor.update(:"#{method}_md5" => Unified2.send(method).send(:md5))
          end
        end
      end

      def start
        logger.say(:info, "Initializing unified2 for monitoring.")
        Unified2.watch(Config.unified2, @sensor.last_event_id ? @sensor.last_event_id + 1 : :first) do |event|
          next if event.signature.blank?

          logger.say(:info, "#{event.sensor.id}.#{event.id}")
          
          puts event if logger.debug?

          insert_event = Event.new({
                                     :event_id => event.id,
                                     :checksum => event.checksum,
                                     :created_at => event.timestamp,
                                     :sensor_id => event.sensor.id,
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
                                     :signature_id => event.signature.id
          })

          if insert_event.save
            insert_event.update_sensor
          else
            logger.say(:fail, "Error: #{insert_event.errors}")
          end

        end
      end

    end
  end
end
