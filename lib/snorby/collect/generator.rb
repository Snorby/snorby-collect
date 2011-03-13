require 'unified2'
require 'fileutils'
require 'erb'

module Snorby
  module Collect
    module Generator

      @@template_dir = File.join(File.dirname(__FILE__), 'data')

      def Generator.configuration_file(path, file)
        @version = Snorby::Collect::VERSION
        @hostname = Socket.gethostname
        template = File.read(File.join(@@template_dir, 'options.erb'))
        
        unless File.exists?(file)
          FileUtils.mkdir_p(path)
          config_file = File.open(file, 'w') do |file|
            file.puts ERB.new(template).result(binding)
            file.close
          end
        end
        
        if (editor = Env.editor)
          STDOUT.flush && `#{editor} #{file.to_s}`
        else
          STDOUT.flush && `nano #{file.to_s}`
        end
      end

    end
  end
end
