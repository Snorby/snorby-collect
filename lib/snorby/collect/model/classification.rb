require 'progressbar'

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

        # belongs_to :severity

        validates_uniqueness_of :name, :classification_id

        def self.import(options={})

          if options.has_key?(:classifications)

            unless Snorby::Collect.logger.quiet?
              pbar = ProgressBar.new('Classifica...', options[:classifications].size)
              pbar.bar_mark = 'X'
            end

            options[:classifications].each do |key,value|
              classification = Classification.get(:classification_id => key)
              next if classification && !options[:force]

              if classification
                classification.update(value)
              else
                value.merge!(:classification_id => key)
                Classification.create(value)
              end

              pbar.inc unless Snorby::Collect.logger.quiet?
            end

            pbar.finish unless Snorby::Collect.logger.quiet?
          end
        end

      end

    end
  end
end
