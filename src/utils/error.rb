class OutOfScopeError < StandardError
  def initialize(symbol)
    msg = "#{symbol} is out of scope."
    super(msg)
  end
end

class DuplicateDefinitionError < StandardError
  def initialize(symbol)
    msg = "#{symbol} is already defined."
    super(msg)
  end
end

class UndefinedVariable < StandardError
  def initialize(symbol)
    msg = "#{symbol} is not defined."
    super(msg)
  end
end

class ParameterCountError < StandardError
  def initialize(symbol, _in, expected)
    msg = "#{symbol} function 
          Expected #{expected} 
          got #{_in} parameter#{_in > 1 ? 's' : ''}."
    super(msg)
  end
end

class TypeError < StandardError
  def initialize(symbol)
    msg = "#{symbol}  TYPE ERROR."
    super(msg)
  end
end

class ProcedureTypeError < StandardError
  def initialize(symbol)
    msg = "#{symbol} incompatible types for procedure."
    super(msg)
  end
end

class VariableAlreadyDeclaredError < StandardError
  def initialize(symbol)
    msg = "#{symbol} has already been declared."
    super(msg)
  end
end



# =============== COMPILE TIME ERRROR TILL OSS OM VI ÄR DUMMA

class InferredTypeError < StandardError
  def initialize(symbol)
    msg = "#{symbol} has already been given a type."
    super(msg)
  end
end

class CompilerError < StandardError
  def initialize()
    msg = "Compiler error."
    super(msg)
  end
end

class OperationNotAllowed < StandardError

  def initialize()
      msg = "Operation not allowed!"
      super(msg)
  end
end


class NoTypeError < StandardError

  def initialize()
      msg = "Type is used before compile time initialization."
      super(msg)
  end
end
  

class ChangeOfTypeError < StandardError

  def initialize()
      msg = "Changing type is not allowed."
      super(msg)
  end
end
 
class TypeIsNotInstanciableError < StandardError

  def initialize()
      msg = "Changing type is not allowed"
      super(msg)
  end
end

class ProgrammerError < StandardError

  def initialize()
      msg = "You are broken, not the code. Seek help!"
      super(msg)
  end
end