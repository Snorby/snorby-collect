module Snorby
  module Collect
    module Model

      class Signature
        include DataMapper::Resource

        storage_names[:default] = "signatures"

        timestamps :created_at, :updated_at

        property :id, Serial, :index => true

        property :signature_id, Integer, :index => true

        property :generator_id, Integer, :index => true

        property :name, Text
        
        property :revision, Integer

        has n, :events

        validates_uniqueness_of :name

      end

    end
  end
end
