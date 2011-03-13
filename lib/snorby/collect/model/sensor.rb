module Snorby
  module Collect
    module Model
      
      class Sensor
        include DataMapper::Resource
        storage_names[:default] = "sensors"
        
        timestamps :created_at, :updated_at

        property :id, Serial, :index => true

        property :hostname, Text, :index => true

        property :interface, String

        property :name, String, :index => true

        property :last_event_id, Integer, :index => true

        property :signatures_md5, String, :length => 32, :index => true

        property :generators_md5, String, :length => 32, :index => true

        property :classifications_md5, String, :length => 32, :index => true

        has n, :events

        validates_uniqueness_of :hostname, :scope => :interface
        validates_uniqueness_of :interface, :scope => :hostname
        validates_uniqueness_of :name

        def events_count
          last_event_id
        end

        def self.find(object)
          name = object.name ? object.name : object.hostname

          sensor = first_or_create({:hostname => object.hostname, :interface => object.interface}, {
            :hostname => object.hostname, 
            :interface => object.interface,
            :name => name,
          })
          
          unless sensor.errors.empty?
            sensor.errors.each do |key, value|
              fail("Sensor Validation Error: #{key}")
            end
            exit -1
          end
          
          sensor
        end

      end
      
    end
  end
end