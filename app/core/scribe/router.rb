module Scribe
  class Router
    attr_accessor :level, :formatter, :outputter

    def initialize(level, formatter, outputter)
      @level = level
      @formatter = formatter
      @outputter = outputter
    end

    def send(msg)
      if msg.level >= @level
        @outputter << @formatter.format(msg)
      end
    end
  end
end