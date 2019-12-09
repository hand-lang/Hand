require_relative '../utils/index'
require_relative 'type'

class Procedure < HandObject
  
  def initialize(operand_a, operation, operand_b)
    @operand_a = operand_a
    @operand_b = operand_b
    @operation = operation
  end 

  def assemble(memory)
    store_operand_a = @operand_a.assemble(memory)

    operand_a_addr = memory.read_temp

    store_operand_b = @operand_b.assemble(memory)
    
    operand_b_addr = memory.read_temp            

    operand_a_value   = memory.load(operand_a_addr, 'r4')
    operand_b_value   = memory.load(operand_b_addr, 'r3')


    procedure_inst   = "#{@operation} r3, r4, r3"
    
    memory.clear_temp(2)

    store_inst = memory.store_to_temp("r3")

    [store_operand_a, store_operand_b, operand_a_value, operand_b_value, procedure_inst, store_inst].asm_join()
  end

  def bind_scope(scope)
    @operand_a.bind_scope(scope)
    @operand_b.bind_scope(scope)
  end

  def get_type()
    a_type = @operand_a.get_type()
    b_type = @operand_b.get_type()
    # TODO EXPELL ME
    raise ProcedureTypeError.new(@operation) unless (HIntegerType == a_type || HAutoType == a_type) && (HIntegerType == b_type || HAutoType == b_type)
    return HIntegerType
  end

  def semantic_check()
    get_type()
  end

end

class HAdd < Procedure
  def initialize(operand_a, operand_b)
    super(operand_a, "add", operand_b)
  end


  def type()
    @operand_a.type        
  end
end


class HSub < Procedure
  def initialize(operand_a, operand_b)
    super(operand_a, "sub", operand_b)
  end
end

class HMul < Procedure
  def initialize(operand_a, operand_b)
    super(operand_a, "mul", operand_b)
  end
end

class HDiv < Procedure
  def initialize(operand_a, operand_b)
    super(operand_a, "udiv", operand_b)
  end
end
