class StringLiteral
    attr_reader :value, :quoted
  
    def initialize(value)
      @value  = value
      @quoted = "\"#{@value}\""
    end
  
  end
  