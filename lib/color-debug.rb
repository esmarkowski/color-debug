require 'active_support'

module ActiveSupport
  class BufferedLogger
    module Colors
      YELLOW="\e[0;33m"
      GREEN="\e[0;32m"
      BLUE="\e[0;34m"
      RED="\e[0;31m"
      MAGENTA="\e[0;45m"
      CYAN="\e[0;36m"
      WHITE="\e[0;37m"
      EC="\e[0;0m"
    end
    module Severity
      COLORIZE = 10
    end
    include Severity
    def add(severity, message = nil, progname = nil, color = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      color ||= Colors::MAGENTA
      message = "#{color}#{message}#{Colors::EC}\n" if severity == 10
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
    
    for severity in Severity.constants
          class_eval <<-EOT, __FILE__, __LINE__ + 1
            def #{severity.downcase}(message = nil, progname = nil, color = nil, &block) # def debug(message = nil, progname = nil, &block)
              add(#{severity}, message, progname, color, &block)                   #   add(DEBUG, message, progname, &block)
            end                                                             # end

            def #{severity.downcase}?                                       # def debug?
              #{severity} >= @level                                         #   DEBUG >= @level
            end                                                             # end
          EOT
        end
  end
end