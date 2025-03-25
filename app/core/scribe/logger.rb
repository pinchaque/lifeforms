module Scribe
  class Logger
    attr_accessor :routers

    def initialize(*routers)
      @routers = *routers
    end
    
    # Outputs log message string and context at the specified log level
    def log(msg)
      @routers.each { |r| r.send(msg) }
    end

    # Outputs error log message with specified context
    def error(str, **context)
        log(Message.new(Level::ERROR, str, **context))
    end

    # Outputs warning log message with specified context
    def warning(str, **context)
        log(Message.new(Level::WARNING, str, **context))
    end

    # Outputs informational log message with specified context
    def info(str, **context)
        log(Message.new(Level::INFO, str, **context))
    end

    # Outputs debugging log message with specified context
    def debug(str, **context)
        log(Message.new(Level::DEBUG, str, **context))
    end

    # Outputs debug trace log message with specified context
    def trace(str, **context)
        log(Message.new(Level::TRACE, str, **context))
    end
  end
end