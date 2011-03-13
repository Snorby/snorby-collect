require 'snorby/collect/cli'
require 'snorby/collect/config'
require 'snorby/collect/generator'
require 'snorby/collect/version'

module Snorby
  module Collect
    
    def self.logger=(logger)
      @logger = logger
    end
    
    def self.logger
      @logger
    end
    
  end
end
