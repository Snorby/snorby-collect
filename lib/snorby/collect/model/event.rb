require 'snorby/collect/model/signature'

module Snorby
  module Collect
    module Model

      class Event
        include DataMapper::Resource
        storage_names[:default] = "events"

        timestamps :created_at, :updated_at

        is :counter_cacheable

        property :id, Serial, :index => true

        property :checksum, String, :index => true

        property :event_id, Integer, :index => true

        property :host_id, Integer, :index => true

        property :sensor_id, Integer, :index => true

        property :severity_id, Integer, :index => true

        property :source_ip, String, :index => true

        property :source_port, Integer

        property :destination_ip, String, :index => true

        property :destination_port, Integer

        property :severity_id, Integer, :index => true

        property :classification_id, Integer, :index => true

        property :category_id, Integer, :index => true

        property :user_id, Integer, :index => true

        property :protocol, String, :index => true

        property :link_type, Integer

        property :packet_length, Integer

        property :packet, Text

        belongs_to :host

        belongs_to :sensor

        belongs_to :classification

        belongs_to :signature

        belongs_to :severity

        counter_cacheable :classification

        counter_cacheable :signature

        #counter_cacheable :severity

        validates_uniqueness_of :event_id, :scope => :sensor_id

        def update_sensor
          sensor.update(:last_event_id => self.event_id)
          sensor.save
        end

      end

    end
  end
end
