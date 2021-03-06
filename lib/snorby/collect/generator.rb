require 'snorby/collect/helpers'
require 'bcrypt'
require 'fileutils'
require 'erb'

module Snorby
  module Collect
    module Generator
      extend Collect::Helpers
      
      @@template_dir = File.join(File.dirname(__FILE__), 'data')

      def Generator.configuration_file(path, file)
        @version = Snorby::Collect::VERSION
        
        template = File.read(File.join(@@template_dir, 'options.erb'))
        
        unless File.exists?(file)
          FileUtils.mkdir_p(path)
          
          config_file = File.open(file, 'w') do |file|
            file.puts ERB.new(template).result(binding)
            file.close
          end
        end

      end

    end
  end
end
