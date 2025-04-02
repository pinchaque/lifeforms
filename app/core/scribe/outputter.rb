module Scribe


  # Classes that output log messages to a destination
  module Outputter

    # Outputs messages to stderr
    class Stderr
      def <<(str)
        $stderr << str
      end
    end

    # Outputs messages to stdout
    class Stdout
      def <<(str)
        $stdout << str
      end
    end

    # Outputs messages to a file with rotation when it gets too large
    class File
      # Directory where log files are written
      attr_accessor :dir

      # Basename to use for log files (i.e. the part without .log)
      attr_accessor :basename

      # Size at which log files are rotated (bytes)
      attr_accessor :rotate_size

      # Number of rotated log files to retain
      attr_accessor :num_retain

      def initialize(dir, basename)
        @dir = dir
        @basename = basename
        @rotate_size = 1_000_000
        @num_retain = 10
        ensure_writeable
      end

      def file_name(i = nil)
        "#{@dir}/#{@basename}.log" + (i.nil? ? "" : ".#{i}")
      end
   
      # Outputs str to the log file 
      def <<(str)
        ::File.open(file_name, "a") do |f|
          f << str
        end
        rotate if ::File.size(file_name) > @rotate_size
      end

      private

      # Ensures that the log directory and file are writeable, creating an
      # empty log file in the process (if it doesn't exist)
      def ensure_writeable
        begin
          Dir.mkdir(@dir) unless Dir.exist?(@dir)
        rescue Exception => ex
          raise "Failed to create log directory '#{@dir}'"  
        end
        begin
          ::File.open(file_name, "a") do |f|
            f << "" # no-op to ensure writeability
          end
        rescue Exception => ex
          raise "Failed to create log file '#{file_name}'"  
        end
      end

      def rotate
        # rotate the higher number log files; will overwrite the highest
        i = @num_retain
        while i >= 2 do
          ::File.rename(file_name(i - 1), file_name(i)) if ::File.exist?(file_name(i - 1))
          i -= 1
        end

        # manage rotation of file_name
        if @num_retain > 0
          ::File.rename(file_name, file_name(1))
        else
          ::File.delete(file_name)
        end
        ensure_writeable
      end
    end
  end
end