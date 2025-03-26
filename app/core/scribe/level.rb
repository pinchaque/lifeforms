module Scribe
  # Levels that a Message can be.
  module Level
    ERROR = 1
    WARNING = 2
    INFO = 3
    DEBUG = 4
    TRACE = 5

    def self.level_to_s(i)
      case i
      when Scribe::Level::ERROR
        "ERROR"
      when Scribe::Level::WARNING
        "WARNING"
      when Scribe::Level::INFO
        "INFO"
      when Scribe::Level::DEBUG
        "DEBUG"
      when Scribe::Level::TRACE
        "TRACE"
      else
        "UNKNOWN"
      end
    end
  end
end