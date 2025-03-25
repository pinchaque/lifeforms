module Scribe
  class Msg
    attr_accessor :msg, :context, :level, :time

    def initialize(level, msg, **context)
      @level = level
      @msg = msg
      @context = context
      @time = DateTime.now
    end

    def self.error(msg, **context)
      self.new(Level::ERROR, msg, **context)
    end

    def self.warning(msg, **context)
      self.new(Level::WARNING, msg, **context)
    end

    def self.info(msg, **context)
      self.new(Level::INFO, msg, **context)
    end

    def self.debug(msg, **context)
      self.new(Level::DEBUG, msg, **context)
    end

    def self.trace(msg, **context)
      self.new(Level::TRACE, msg, **context)
    end
  end
end