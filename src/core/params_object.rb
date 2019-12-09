
require_relative '../utils/index'
require_relative 'type'

class HParamWriter < HandObject
    include Semantic
    
    def initialize(variable)
        @variable = variable
    end
    
    def bind_scope(scope)
        @variable.bind_scope(scope)
    end
    
    def get_type()
        return @variable.get_type()
    end

    def assemble(memory)
        load_var_to_temp = @variable.assemble(memory)
        load_register    = memory.load_temp_to('r3')
        memory.clear_temp(1) # WTF
        store_inst       = memory.store_to_temp('r3')
        [load_var_to_temp, load_register, store_inst].asm_join
    end

end


class HParamReader < HandObject
    include Semantic
    attr_reader :symbol 
    attr_accessor :offset

    def initialize(symbol, type = HAutoType)
        @symbol = symbol
        @type = type
    end

    def assemble(memory)
        load_to_reg  = "ldr r3, [fp, #{offset.to_asm}]"
        load_to_temp = memory.store_to_temp("r3")
        [load_to_reg, load_to_temp].asm_join
    end

    def bind_scope(scope)
        scp_obj = ScopeObject.new(@symbol, @type)
        scope.add_to_scope(scp_obj)
    end

    def get_type()
        return @type
    end

    def signature()
        return [@type, @symbol].compact.join("")
    end

end 

# FUNCTION DEFINITION
class HParamsReaderObject < HandObject
    def initialize(params = [])
        @params = params
        for i in (0...@params.length)
            @params[i].offset = (i+1) * 4
        end
    end

    def assemble(memory)
        @params.each {|param|
            memory.add_variable(param)
        }
        return ""
    end

    def bind_scope(scope)
        @params.each {|param| param.bind_scope(scope) }
    end

    def signature()
        return @params.reduce("") {|sig, param| sig + param.sig }
    end

    def get(num)
        @params[num-1]
    end

    def size()
        @params.size
    end
    
    def type_list()
        @params.map {|param| param.get_type}
    end
end 

#= FUNCTION CALLS
class HParamsWriterObject < HandObject
    def initialize(params = [])
        @params = params
    end

    def assemble(memory)
        complete_list = @params.reverse.reduce([]) {|inst_list, param|
            inst_list.push(param.assemble(memory))
        }
        complete_list.asm_join()
    end

    def size()
        @params.size
    end

    def signature()
        return @params.reduce("") {|sig, param| sig + param.sig }
    end

    def bind_scope(scope)
        @params.each {|param| param.bind_scope(scope) }
    end

    def type_list()
        @params.map {|param| param.get_type}
    end
end 