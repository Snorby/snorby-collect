module Snorby
  module Collect
    module Model

      class Severity
        include DataMapper::Resource
        
        storage_names[:default] = "severities"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true
        
        property :severity_id, Integer, :index => true
        
        property :name, String, :unique => true
        
        property :text_color, String, :default => '#fff'
        
        property :bg_color, String, :default => '#ddd'

        has n, :events

        has n, :classifications
      
        validates_uniqueness_of :severity_id
      
        def self.build_defaults
          if Severity.all.blank?
            Severity.create(:id => 1, :severity_id => 1, :name => 'High Severity', :text_color => "#ffffff", :bg_color => "#ff0000")
            Severity.create(:id => 2, :severity_id => 2, :name => 'Medium Severity', :text_color => "#ffffff", :bg_color => "#fab908")
            Severity.create(:id => 3, :severity_id => 3, :name => 'Low Severity', :text_color => "#ffffff", :bg_color => "#3a781a")
            Severity.create(:id => 4, :severity_id => 4, :name => 'Information Severity', :text_color => "#ffffff", :bg_color => "#3a781a")
          end
        end
        
      end
      
    end
  end
end
