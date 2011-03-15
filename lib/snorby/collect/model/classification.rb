module Snorby
  module Collect
    module Model

      class Classification
        include DataMapper::Resource

        storage_names[:default] = "classifications"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true

        property :classification_id, Integer, :index => true

        property :name, Text

        property :short, String

        property :severity_id, Integer, :index => true

        has n, :events

        belongs_to :severity

        validates_uniqueness_of :name, :classification_id

      end

    end
  end
end
