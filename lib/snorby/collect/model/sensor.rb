require 'snorby/collect/model/host'

module Snorby
  module Collect
    module Model

      class Sensor
        include DataMapper::Resource
        storage_names[:default] = "sensors"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true

        property :interface, String

        property :name, String, :index => true

        property :checksum, String, :length => 32, :index => true

        property :host_id, Integer, :index => true

        property :last_event_id, Integer, :index => true

        has n, :events

        belongs_to :host

        validates_uniqueness_of :name, :checksum
        validates_presence_of :interface, :name, :checksum, :host_id

        def events_count
          last_event_id
        end

        def self.find(object)

          host = Host.first_or_create({ :hostname => object.hostname }, {
            :hostname => object.hostname
          })

          sensor = first(:host_id => host.id, :name => object.name, :checksum => object.checksum)

          if sensor
            sensor.update(
              {
                :interface => object.interface,
                :name => object.name,
                :checksum => object.checksum
              }
            )
          else
            sensor = host.sensors.create(
              {
                :interface => object.interface,
                :name => object.name,
                :checksum => object.checksum
              }
            )
          end

          unless sensor.errors.empty?
            sensor.errors.each do |key, value|
              fail("Sensor Validation Error: #{key}! You may be trying to add a duplicate logical sensor.")
            end
            exit -1
          end

          [sensor, host]
        end

      end

    end
  end
end
