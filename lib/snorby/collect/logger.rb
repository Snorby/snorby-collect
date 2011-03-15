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
        if @level == :verbose
          return true unless @daemon
          return false
        end
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
