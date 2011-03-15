module Snorby
  module Collect
    module Model

      class Host
        include DataMapper::Resource

        storage_names[:default] = "hosts"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true

        property :hostname, String, :index => true

        property :signatures_md5, String, :length => 32, :index => true

        property :generators_md5, String, :length => 32, :index => true

        property :classifications_md5, String, :length => 32, :index => true

        has n, :events
        
        has n, :sensors
        
      end
      
    end
  end
end
