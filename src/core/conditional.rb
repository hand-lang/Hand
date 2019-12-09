require_relative '../utils/index'
require_relative '../system/index'


class HConditional < HandObject

  def initialize(condition, block)
      @condition = condition
      @block = block
  end

  def bind_scope(scope)
      @condition.bind_scope(scope)
      scope.add_scope
      @block.bind_scope(scope)
      scope.remove_last
  end

  def semantic_check()
    @condition.semantic_check()
    @block.semantic_check()
  end
  
end


class HLoop < HConditional

  def assemble(memory)
      start_label =  LabelGenerator.shared.generate_statement_label
      exit_label  =  LabelGenerator.shared.generate_statement_label

      start_inst      = "#{start_label}:"
      condition_inst  = @condition.assemble(memory) # är en procedure
      load_comparator = memory.load_temp_to("r3")
      test_condition  = "cmp r3, #1"
      exit_brancher   = "bne " + exit_label
      block_inst      = @block.assemble(memory)
      redo_brancher   = "b " + start_label
      end_label       = "#{exit_label}:"

      [start_inst, condition_inst, load_comparator, 
      test_condition, exit_brancher, block_inst, redo_brancher, 
      end_label].asm_join()
  end
  
end

class HIf < HConditional
  
  def initialize(condition, if_block, else_block = nil)
      super(condition, if_block)
      @else_block = else_block
  end

  def assemble(memory)
      else_label = LabelGenerator.shared.generate_statement_label
      exit_label = LabelGenerator.shared.generate_statement_label

      condition_inst  = @condition.assemble(memory) # är en procedure
      load_comparator_inst = memory.load_temp_to("r3")
      test_condition_inst  = "cmp r3, #1"
      exit_brancher_inst   = "bne " + else_label
      if_block_inst   = @block.assemble(memory)
      
      branch_else_inst = nil
      else_start       = nil
      else_block_inst  = nil
      
      if @else_block
          branch_else_inst = "b " + exit_label
          else_start  = "#{else_label}:"
          else_block_inst  = @else_block.assemble(memory)
      end

      end_label = "#{exit_label}:"

      [ condition_inst,     load_comparator_inst, test_condition_inst, 
        exit_brancher_inst, if_block_inst,        branch_else_inst, 
        else_start,    
        else_block_inst, 
        end_label ].asm_join()
  end
  
end