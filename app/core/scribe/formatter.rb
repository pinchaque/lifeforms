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

    # Returns the color to use for the specified level
    def level_color(level)
      case level
      when Scribe::Level::ERROR
        TermColor.new.red
      when Scribe::Level::WARNING
        TermColor.new.yellow
      when Scribe::Level::INFO
        TermColor.new.blue
      when Scribe::Level::DEBUG
        TermColor.new.cyan
      when Scribe::Level::TRACE
        TermColor.new.cyan
      end
    end

    # Extracts Lifeform-specific ID info to put at the start of the log msg
    def extract_id(ctx)
      id = nil
      ret = {}
      ctx.each do |k, v|
        if k == :lf && v.class == Lifeform
          id = "#{v.id} #{v.name}"
        else
          ret[k] = v
        end
      end
      return id, ret
    end

    # Formats the given message for output to a log and returns the formatted
    # string.
    def format(msg)
      grey = TermColor.new.reset.grey
      magenta = TermColor.new.magenta
      white = TermColor.new.white
      reset = TermColor.new.reset

      id, ctx = extract_id(msg.context)

      phrases = []
      phrases << "#{grey}[#{fmt_time(msg.time)}]"
      phrases << "#{magenta}#{id}" unless id.nil?
      phrases << "#{level_color(msg.level)}#{Scribe::Level.level_to_s(msg.level)}"
      phrases << "#{white}#{msg.msg}"
      phrases << "[#{fmt_context(ctx)}]" unless ctx.empty?
      phrases.join(" ") + "#{reset}\n"
    end
  end
end