module Snorby
  module Collect
    class Logger

      attr_accessor :timestamp, :level, :daemon

      def initialize(level=:none, daemon=false)
        @level = level.to_sym
        @timestamp = true
        @daemon = daemon
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

      def say(type, message, log_file=nil, both=false)
        return unless verbose? || debug?
        timestamp, @timestamp = @timestamp, true

        reply = case type.to_sym
        when :info
          info(message)
        when :warn
          warn(message)
        when :fail
          fail(message)
        end
        
        if ((log_file) && File.exists?(log_file))
          log = File.new(log_file, "a")
          log.sync = true
          log.puts reply
          log.close
          puts reply if both
        else
          puts reply
        end
        
        @timestamp = timestamp
      end

      def info(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        "[INFO] #{time} #{message}"
      end

      def warn(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        "[WARN] #{time} #{message}"
      end

      def fail(message)
        time = @timestamp ? "[#{Time.now.strftime('%D %H:%M:%S')}]" : "\b"
        "[FAIL] #{time} #{message}"
      end

    end
  end
end
