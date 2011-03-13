require 'snorby/collect/logger'

module Snorby
  module Collect
    module Helpers

      def logger
        Snorby::Collect.logger
      end

      def logger=(logger)
        Snorby::Collect.logger = logger
      end

    end
  end
end
