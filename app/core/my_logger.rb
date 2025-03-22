require 'date'

# Class that handles logging for the application.
class MyLogger
    ERROR = 1
    WARNING = 2
    INFO = 3
    DEBUG = 4
    TRACE = 5

    attr_accessor :level

    # Initialize with the log level we are outputting and the IO object to
    # which logs will be written (e.g. $stderr)
    def initialize(level, outf)
      @level = level
      @outf = outf
    end

    # Helper function for formatting time in log message output
    def fmt_time
        DateTime.now.strftime("%F %T") 
    end

    # Helper function for formatting log message context
    def fmt_context(h)
      h.keys.sort.map { |k| "#{k}:#{h[k]}" }.join(", ")
    end

    # Formats the log message for output, including time and context
    def log_str(str, context)
      s = "[#{fmt_time}] #{str}"
      s += " [#{fmt_context(context)}]" unless context.empty?
      s
    end

    # Outputs log message string and context at the specified log level
    def log(level, str, context = {})
        return if level > @level
        @outf << log_str(str, context) + "\n"
    end

    # Outputs error log message with specified context
    def error(str, context = {})
        log(MyLogger::ERROR, str, context)
    end

    # Outputs warning log message with specified context
    def warning(str, context = {})
        log(MyLogger::WARNING, str, context)
    end

    # Outputs informational log message with specified context
    def info(str, context = {})
        log(MyLogger::INFO, str, context)
    end

    # Outputs debugging log message with specified context
    def debug(str, context = {})
        log(MyLogger::DEBUG, str, context)
    end

    # Outputs debug trace log message with specified context
    def trace(str, context = {})
        log(MyLogger::TRACE, str, context)
    end
end