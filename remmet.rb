require 'pp'  # DEBUG

module Remmet
  class Parser
    def initialize()
      @split_pattern = />|\+|\^/
      @tokens = []
    end

    def parse(string)
      s = ''
      string.split('').each do |token|
        s << token
        if token.match(@split_pattern) != nil
          s = ''
          @tokens << s
        end
      end
      PP.pp(@tokens)
    end
  end
end

parser = Remmet::Parser.new()
s = 'Vehicle>#Car>.drive+.stop+.start^#Airplane>.start+.stop'
puts(s)
parser.parse(s)
