module Snorby
  module Collect
    module Model
      
      class Tcp
        include DataMapper::Resource

        storage_names[:default] = "tcphdr"

        property :id, Serial, :index => true

        property :event_id, Integer, :index => true

        property :seq, String, :lazy => true, :required => true, :default => 0, :length => 15

        property :ack, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :hlen, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :res, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :flags, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :win, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :csum, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :urg, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :length, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :reserved, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :ecn, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :opts_len, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :rand_port, Integer, :lazy => true, :min => 0, :required => true, :default => 0

        property :options, String, :lazy => true

        belongs_to :event

      end
      
    end
  end
end
