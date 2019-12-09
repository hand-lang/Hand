
require_relative '../utils/index'
require_relative '../system/label_generator'
require_relative 'type'

class HAssignment < HandObject    
    attr_reader :var

    def initialize(symbol, input)
        @input = input
        @symbol = symbol
    end

    def assemble(memory)
        rhs_inst   = @input.assemble(memory)
        pseudo_type = HIntegerType
        load_inst  = memory.load_temp_to('r3')
        store_inst = memory.store_to_perm('r3')
        @var = HVariableReader.new(@symbol, memory.read_perm) # en rad i minnet
        @var.set_type(pseudo_type)
        memory.add_variable(@var)
        memory.clear_temp(1) # TODO: mer än en rad behövs inte
        [rhs_inst, load_inst, store_inst].asm_join()
    end

    def bind_scope(scope)
        if (scope.in_flat(@symbol))
            raise VariableAlreadyDeclaredError.new(@symbol)
        end
        @input.bind_scope(scope)
        scp_obj = ScopeObject.new(@symbol, @input.get_type())
        scope.add_to_scope(scp_obj)
    end

    def semantic_check()
        @input.semantic_check()
    end
end

class HReassignment < HandObject    
    attr_reader :var

    def initialize(symbol, input)
        @input        = input
        @symbol       = symbol
        @scope_object = nil
    end

    def assemble(memory)
        input_value         = @input.assemble(memory)
        @variable           = memory.get_variable(@symbol)
        load_from_temp      = memory.load_temp_to('r3')
        store_from_register = memory.store('r3',@variable.offset)
        [input_value, load_from_temp, store_from_register].asm_join
    end
 
    def bind_scope(scope)
        raise OutOfScopeError.new(@symbol) unless scope.in_scope(@symbol)
        @scope_object = scope.get(@symbol)
        @input.bind_scope(scope)
    end

    def semantic_check()
        input_type   = @input.get_type
        current_type = @scope_object.type

        if (current_type == HAutoType && input_type != HAutoType) 
            @scope_object.give_type(input_type)
            return
        end

        raise TypeError.new(@symbol) unless current_type == input_type
        @input.semantic_check()
    end
end


class HVariableReader < HandObject
    include Accessible
    attr_reader :symbol, :type, :offset

    def initialize(symbol, offset)
        @symbol = symbol
        @offset = offset
        @type   = nil
    end

    def assemble(memory)
        load_inst  = "ldr r3, [fp, ##{@offset}]"
        store_inst = memory.store_to_temp("r3")
        [load_inst, store_inst].asm_join()
    end

    #def bind_scope(scope)
    #    raise OutOfScopeError.new(@symbol) unless scope.in_scope(@symbol) # ett fel
    #end

    def get_type()
        raise NoTypeError.new unless @type
        return @type
    end

    def set_type(meta_type)
        raise ChangeOfTypeError.new if self.send("#{:type}")
        #self.send("#{:type}=",meta_type)
        @type = meta_type
    end
end

class HLiteral < HandObject
    
    def initialize(meta_type) #Meta
        @meta = meta_type
    end

    def assemble(memory)
        #ALTERNATIVE: store_register_to_temp_before use and then reload to r3 = ""
        load_inst  = @meta.load("r3", memory)
        store_inst = memory.store_to_temp("r3")
        [load_inst, store_inst].asm_join()
    end

    def bind_scope(scope) #TODO what the fuzz
    end

    def get_type()
        return @meta.get_type()
    end

end

class HIdentifier < HandObject
  
    def initialize(symbol)
        @symbol       = symbol
        @scope_object = nil
    end

    def bind_scope(scope)
        raise OutOfScopeError.new(@symbol) unless scope.in_scope(@symbol)
        @scope_object = scope.get(@symbol)
    end

    def get_type()
        raise ProgrammerError.new unless @scope_object
        @scope_object.type
    end

    def assemble(memory)
        memory.get_variable(@symbol).assemble(memory)
    end
end