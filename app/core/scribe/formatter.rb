module Scribe
  # Class that takes the data from the Message (i.e. timestamp, level, string, 
  # context) and formats it into a string for outputting.
  class Formatter
    attr_accessor :colorize

    def initialize(colorize = true)
      @colorize = colorize
    end

    # Helper function for formatting time in log message output
    def fmt_time(time)
      time.strftime("%F %T") 
    end

    # Helper function for formatting log message context
    def fmt_context(h)
      h.keys.map { |k| "#{k}:#{h[k]}" }.join(", ")
    end

    class TermColorDummy
      def to_s
        ""
      end

      def method_missing(method_name, *args)
        # do nothing
        self
      end
    end

    def color_class
      @colorize ? TermColor : TermColorDummy
    end

    # Returns the color to use for the specified level
    def level_color(level)
      case level
      when Scribe::Level::ERROR
        color_class.new.red
      when Scribe::Level::WARNING
        color_class.new.yellow
      when Scribe::Level::INFO
        color_class.new.blue
      when Scribe::Level::DEBUG
        color_class.new.cyan
      when Scribe::Level::TRACE
        color_class.new.cyan
      end
    end

    # Helper method that takes an object with an id and name and turns it into
    # a short string useful for output.
    def obj_name(obj)
      "#{obj.id[0..5]} #{obj.name}"
    end

    # Extracts object-specific ID info to put at the start of the log msg
    def extract_id(ctx)
      # keys and objects we are extracting      
      objs = {
        # env: Environment,
        # lf: Lifeform
      }

      # Populate ids with the strings we have available in the order given by
      # objs
      ids = []
      objs.each do |k, klass|
        obj = ctx[k]
        if !obj.nil? && obj.class == klass 
          ids << obj_name(obj)
        end
      end

      id = ids.empty? ? nil : ids.join(" > ")
      ret = ctx.reject { |k, v| objs.key?(k) && objs[k] == v.class }
      return id, ret
    end

    # Formats the given message for output to a log and returns the formatted
    # string.
    def format(msg)
      grey = color_class.new.reset.grey
      magenta = color_class.new.magenta
      white = color_class.new.white
      reset = color_class.new.reset

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