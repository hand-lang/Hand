require_relative '../utils/index'
require_relative '../system/index'
class Logical < HandObject

    def initialize(operand_a, operand_b, cmp_val, *labels)
        @operand_a  = operand_a
        @operand_b  = operand_b
        @cmp_val = cmp_val
        @true_label, @false_label, @exit_label, @branch_label = *labels
    end

    def assemble(memory)
        store_operand_a = @operand_a.assemble(memory)

        operand_a_addr = memory.read_temp

        store_operand_b = @operand_b.assemble(memory)
    
        operand_b_addr = memory.read_temp

     
        op_a_value = memory.load(operand_a_addr, 'r3')
        op_b_value = memory.load(operand_b_addr, 'r3')

        first_compare_inst = "cmp r3, #{@cmp_val}"
        second_compare_inst = "cmp r3, #0"

        first_branch = 'beq ' + @branch_label
        false_branch = 'beq ' + @false_label
        #true_branch = 'beq ' + @

        true_result = 'mov r3, #1'
        false_result = 'mov r3, #0'

        store_inst = memory.store_to_temp("r3")

        branch_exit = 'b ' + @exit_label

        [store_operand_a, op_a_value, first_compare_inst, first_branch,
         store_operand_b, op_b_value, second_compare_inst, false_branch, "#{@true_label}:", 
         true_result, store_inst, branch_exit, "#{@false_label}:", false_result, 
         store_inst, "#{@exit_label}:"].asm_join()
    end

    def bind_scope(scope)
        @operand_a.bind_scope(scope)
        @operand_b.bind_scope(scope)
    end

    def semantic_check()
        puts "TODO IMPLEMENT ME"
    end
end

class HLog_And < Logical
    def initialize(operand_a, operand_b)
        true_label  = LabelGenerator.shared.generate_statement_label
        false_label = LabelGenerator.shared.generate_statement_label
        exit_label  = LabelGenerator.shared.generate_statement_label

        super(operand_a, operand_b, '#0', true_label, false_label, exit_label, false_label)
    end
end

class HLog_Or < Logical
    def initialize(operand_a, operand_b)
        true_label  = LabelGenerator.shared.generate_statement_label
        false_label = LabelGenerator.shared.generate_statement_label
        exit_label  = LabelGenerator.shared.generate_statement_label
        super(operand_a, operand_b, '#1', true_label, false_label, exit_label, true_label)
    end
end

=begin

ARM: AND
1    ldr r3, op_a
1    cmp r3, #0
1    beq L2

2    ldr r3, op_b    
2    cmp r3, #0
2    beq L2
L1:
3    mov r3, #1
3    str r3, tmp
3    b L3:
L2:
4    mov r3, #0
4    str r3, tmp
L3:
5--->resultat finns i tmp som bool

ARM: OR
1    ldr r3, op_a
1    cmp r3, #1
1    beq L1

2    ldr r3, op_b    
2    cmp r3, #0
2    beq L2
L1:
3    mov r3, #1
3    str r3, tmp
3    b L3:
L2:
4    mov r3, #0
4    str r3, tmp
L3:
5--->resultat finns i tmp som bool

=end