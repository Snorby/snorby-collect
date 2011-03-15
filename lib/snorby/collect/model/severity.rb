module Snorby
  module Collect
    module Model

      class Severity
        include DataMapper::Resource
        
        storage_names[:default] = "severities"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true
        
        property :severity_id, Integer, :index => true
        
        property :events_count, Integer, :default => 0, :index => true
        
        property :name, String, :unique => true
        
        property :text_color, String, :default => '#fff'
        
        property :bg_color, String, :default => '#ddd'

        has n, :events

        has n, :classifications
        
      end
      
    end
  end
end
