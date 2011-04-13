module Snorby
  module Collect
    module Model
      class Icmp

        include DataMapper::Resource

        storage_names[:default] = "icmphdr"

        property :id, Serial, :index => true

        property :event_id, Integer, :index => true

        property :type, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :code, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :csum, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :length, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        belongs_to :event

      end
    end
  end
end
