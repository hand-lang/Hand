
require_relative '../utils/index'

class Comparison < HandObject
  
  def initialize(operand_a, operand_b, sat_inst, dis_inst)
    @operand_a = operand_a
    @operand_b = operand_b
    @sat_inst  = sat_inst
    @dis_inst  = dis_inst
  end 

  def assemble(memory)
    store_operand_a = @operand_a.assemble(memory)

    operand_a_addr = memory.read_temp

    store_operand_b = @operand_b.assemble(memory)
    
    operand_b_addr = memory.read_temp            

    operand_a_value   = memory.load(operand_a_addr, 'r4')
    operand_b_value   = memory.load(operand_b_addr, 'r3')

    compare_inst      = 'cmp r4, r3'
    procedure_inst    = compare_result('r3')
    
    memory.clear_temp(2)

    store_inst = memory.store_to_temp("r3")



    [store_operand_a, store_operand_b, operand_a_value, operand_b_value, compare_inst, procedure_inst, store_inst].asm_join()
  end

  def compare_result(register)
    sat_cond_inst = "#{@sat_inst} #{register}, #1" 
    dis_cond_inst = "#{@dis_inst} #{register}, #0"
    return [sat_cond_inst, dis_cond_inst].asm_join
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

class HComp_G < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "movgt", "movle")
    end
end

class HComp_L < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "movlt", "movge")
    end
end

class HComp_GE < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "movge", "movlt")
    end
end

class HComp_LE < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "movle", "movgt")
    end
end

class HComp_EE < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "moveq", "movne")
    end
end

class HComp_NE < Comparison
    def initialize(operand_a, operand_b)
      super(operand_a, operand_b, "movne", "moveq")
    end
end

