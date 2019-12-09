
require_relative 'error'

module Scopable
  def self.included base
        base.send :include, InstanceMethods
  end

  module InstanceMethods
    def bind_scope(scope)
        raise NotImplementedError.
            new("#{self.class.name} is an abstract class.")
    end

    def add_scope
        raise NotImplementedError.
        new("#{self.class.name} is an abstract class.")
    end
  end
end


class ScopeObject
    attr_reader :symbol, :type, :related_types
    attr_writer :type
    
    def initialize(symbol, type, related_types = [])
        @symbol = symbol
        @type = type
        @related_types = related_types
    end

    def give_type(type)
        raise InferredTypeError.new(@symbol) unless @type == HAutoType
        @type = type  
    end

    def related_types_count 
        @related_types.size
    end
end

class ScopeList < Array

    def initialize(scope_block)
        super(1, scope_block)
    end
end 

class ScopeBlock < Array
    attr_reader :valid

    def initialize()
        super(0,0)
        @valid = true
    end

    def set_false()
        raise ProgrammerError.new if @valid == false
        @valid = false
    end
end



class Scope
  attr_reader :list 
  
  def initialize(list = ScopeList.new(ScopeBlock.new)) # TODO: REMOVE THIS EXTRA CHILD BECAUSE IT HAS TO BE INITILIAZED FROM OUTER CALLER
      @list = list
  end

  def add_to_scope(scope_object)
      @list.last.push(scope_object)
  end

  def add_scope()
      @list.push(ScopeBlock.new)
  end

  def remove_last()
      @list.pop()
  end

  def in_flat(symbol)
      return !@list.empty? && @list.last.any?{|scp_obj| scp_obj.symbol == symbol }
  end

  def in_scope(symbol)
    exist = @list.any? {|scp_bl| scp_bl.any?{|scp_obj| scp_obj.symbol == symbol } }
    return exist
  end

  def get_flat(symbol)
    @list.last.detect {|scp_obj| scp_obj.symbol == symbol}
  end

  def get(symbol)
    detected = nil
    for scope_block in @list.reverse
        detected = scope_block.detect{|scp_obj| scp_obj.symbol == symbol }
        return detected if detected != nil
    end
    
    raise CompilerError.new if detected == nil
  end

end
