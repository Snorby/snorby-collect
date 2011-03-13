require 'progressbar'

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

        has n, :events

        validates_uniqueness_of :name

        def self.import(options={})

          if options.has_key?(:signatures)
            
            unless Snorby::Collect.logger.quiet?
              pbar = ProgressBar.new('Signatures', options[:signatures].size)
              pbar.bar_mark = 'X'
            end
            
            options[:signatures].each do |key, value|
              signature = Signature.get(:signature_id => key)
              next if signature && !options[:force]

              if signature
                signature.update(value)
              else
                value.merge!(:signature_id => key, :generator_id => 1)
                Signature.create(value)
              end
              pbar.inc unless Snorby::Collect.logger.quiet?
            end
            
            pbar.finish unless Snorby::Collect.logger.quiet?
          end

          if options.has_key?(:generators)

            unless Snorby::Collect.logger.quiet?
              pbar = ProgressBar.new('Generators', options[:generators].size)
              pbar.bar_mark = 'X'
            end
            
            options[:generators].each do |key, value|
              genid, sid = key.split('.')
              signature = Signature.get(:signature_id => sid, :generator_id => genid)
              next if signature && !options[:force]

              if signature
                signature.update(value)
              else
                value.merge!(:signature_id => sid, :generator_id => genid)
                Signature.create(value)
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