module Scribe
  # Class that takes the data from the Message (i.e. timestamp, level, string, 
  # context) and formats it into a string for outputting.
  class Formatter

    def initialize
      # nothing to do (yet)
    end

    # Helper function for formatting time in log message output
    def fmt_time(time)
      time.strftime("%F %T") 
    end

    # Helper function for formatting log message context
    def fmt_context(h)
      h.keys.sort.map { |k| "#{k}:#{h[k]}" }.join(", ")
    end

    # Formats the given message for output to a log and returns the formatted
    # string.
    def format(msg)
      s = "[#{fmt_time(msg.time)}] #{msg.msg}"
      s += " [#{fmt_context(msg.context)}]" unless msg.context.empty?
      s
    end
  end
end