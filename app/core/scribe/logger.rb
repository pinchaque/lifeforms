module Scribe
  class Logger
    attr_accessor :routers

    def initialize(*routers)
      @routers = *routers
    end
    
    # Outputs log message string and context at the specified log level
    def log_message(msg)
      @routers.each { |r| r.send(msg) }
    end

    def log(level, str, **context)
      log_message(Message.new(level, str, **context))
    end

    # Logs and error and aborts the program
    def fatal(str, **context)
      error(str, **context)
      exit 1
    end

    # Outputs error log message with specified context
    def error(str, **context)
        log(Level::ERROR, str, **context)
    end

    # Outputs warning log message with specified context
    def warning(str, **context)
        log(Level::WARNING, str, **context)
    end

    # Outputs informational log message with specified context
    def info(str, **context)
        log(Level::INFO, str, **context)
    end

    # Outputs debugging log message with specified context
    def debug(str, **context)
        log(Level::DEBUG, str, **context)
    end

    # Outputs debug trace log message with specified context
    def trace(str, **context)
        log(Level::TRACE, str, **context)
    end
  end
end