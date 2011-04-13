module Snorby
  module Collect
    module Model
      class Udp

        include DataMapper::Resource

        storage_names[:default] = "udphdr"

        property :id, Serial, :index => true

        property :event_id, Integer, :index => true

        property :length, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :csum, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        belongs_to :event

      end
    end
  end
end
