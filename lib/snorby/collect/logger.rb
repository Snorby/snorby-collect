module Snorby
  module Collect
    class Logger
      
      attr_accessor :timestamp, :level
      
      def initialize(level=:none)
        @level = level.to_sym
        @timestamp = true
      end
      
      def quiet?
        return true if @level == :none
        false
      end
      
      def debug?
        return true if @level == :debug
        false
      end
      
      def verbose?
        return true if @level == :verbose
        false
      end

      def info(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        STDOUT.puts "[INFO] #{time} #{message}"
      end

      def warn(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        STDOUT.puts "[WARN] #{time} #{message}"
      end
      
      def fail(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        STDERR.puts "[FAIL] #{time} #{message}"
      end
      
      def say(type, message)
        return unless verbose? || debug?
        timestamp, @timestamp = @timestamp, true
        STDOUT.sync
        case type.to_sym
        when :info
          info(message)
        when :warn
          warn(message)
        when :fail
          fail(message)
        end
        @timestamp = timestamp
      end
      
    end
  end
end
