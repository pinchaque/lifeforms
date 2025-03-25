module Scribe
  # Class that uses a Message's Level to decide whether it should be formatted
  # and output.
  class Router
    attr_accessor :max_level, :formatter, :outputter

    # Create a router that will send messages <= max_level to the specified
    # outputter after formatting by the specified formatter.
    def initialize(max_level, formatter, outputter)
      @max_level = max_level
      @formatter = formatter
      @outputter = outputter
    end

    # Sends a message through this router.
    def send(msg)
      if msg.level <= @max_level
        @outputter << @formatter.format(msg)
      end
    end
  end
end