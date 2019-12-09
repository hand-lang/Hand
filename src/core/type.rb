class HMetaType
    include Semantic
    def initialize(literal_value = nil)
        @value = literal_value
    end

    def load(register)
        raise NotImplementedError.
            new("#{self.class.name} You can not get a type of a type.")
    end

    def get_type()
        return self.class if @value 
        return HVoidType
    end

    def set_type(param)
        raise OperationNotAllowed.new
    end

end


class HStringType < HMetaType

    def load(register, memory)
        raise OperationNotAllowed.new unless @value
        label = LabelGenerator.shared.generate_data_label
        HDataSectionWriter.shared.store(@value, label)
        load_inst = "ldr #{register}, =#{label}"
        return [load_inst].asm_join
    end

end


class HByteType < HMetaType




end

class HIntegerType < HMetaType

    def load(register, memory)
        raise OperationNotAllowed.new unless @value
        load_inst = nil
       
        if @value >= 4000
            label = memory.add_to_pool(@value)
            load_inst = "ldr #{register}, #{label}"
        else
            load_inst = "mov #{register}, #{@value.to_asm}"
        end

        return [load_inst].asm_join
    end
    
end

class HFunctionType < HMetaType
    def load()
        raise TypeIsNotInstanciableError.new("Function types are loaded by the .text directive.")
    end    
end


class HVoidType < HMetaType
    def load()
        raise TypeIsNotInstanciableError.new("Void is not does not exist in memory.")
    end
end

class HAutoType < HMetaType
    def load()
        raise TypeIsNotInstanciableError.new("Void is not does not exist in memory.")
    end
end