# coding: utf-8
require_relative '../utils/index'
require_relative 'type'
require_relative 'return'

class HFunctionCall < HandObject # stmt är assemblable

  def initialize(name, paramsObject)
    @name = '_' + name
    @paramsObject = paramsObject
  end
  
  def assemble(memory)
      save_real_sp  = memory.store_to_temp('sp')
      params_setup  = @paramsObject.assemble(memory)
      sp_position   = "add sp, fp, #{memory.read_temp.to_asm}"
      call_function = "bl #{signature()}"
      memory.clear_temp(@paramsObject.size)
      revert_sp     = memory.load_temp_to('sp')
      memory.clear_temp(1)
      ret_to_temp   = memory.store_to_temp('r0')
      return [save_real_sp, params_setup, sp_position, call_function, revert_sp, ret_to_temp].asm_join()
  end

  def bind_scope(scope)
    raise OutOfScopeError.new(@name) unless scope.in_scope(@name)
    @scope_object = scope.get(@name)
    @paramsObject.bind_scope(scope)
  end

  def signature()
    "#{@name}" # TODO: plus params object signature
  end

  def get_type()
    @scope_object.type
  end

  def semantic_check()
     in_params = @scope_object.related_types.size
     expected_params = @paramsObject.size
     if !(in_params == expected_params)
        raise ParameterCountError.new(@name, in_params, expected_params)
     end
  end

end
  
class HFunction < HandObject

  attr_reader :name

  def initialize(name, paramsObject,  block)
      @name   = '_' + name
      @paramsObject = paramsObject
      @block  = block
  end

  def setup_asm_code(memory)
      read_params = @paramsObject.assemble(memory)
      start_label = "#{@name}:"
      save_link   = "push {fp, lr}"
      body        = @block.assemble(memory)
      return_inst = @block.returning ? nil : HReturn.new.assemble(memory)
      fp_position = "add fp, sp, #4"
      sp_position = "add sp, sp, #{(memory.read_temp-4).to_asm}" # TODO: temp || perm ? == read_temp
      return [start_label, save_link, fp_position, sp_position, body, return_inst, memory.resolve_pool]
  end

  def assemble(memory)
      setup_asm_code(memory).asm_join()
  end
  
  def bind_scope(scope)
      raise DuplicateDefinitionError.new(@name) if scope.in_scope(@name)
      scope_obj = ScopeObject.new(@name, HFunctionType, @paramsObject.type_list)
      scope.add_to_scope(scope_obj)
      scope.add_scope
      @paramsObject.bind_scope(scope)
      @block.bind_scope(scope)
      scope_obj.type = get_type()
      scope.remove_last
  end

  def get_type()
    @block.get_type()
  end

  def semantic_check()
    @block.semantic_check()
  end

end

class HInitialFunction < HFunction

  def initialize(block)
    super('_initial', HParamsReaderObject.new(), block)
  end

  def name #TODO: Remove name accessor for normal HFunctions
    return '_initial'
  end

end

class HMainFunction < HFunction
  def initialize(name, block)
    super(name, HParamsReaderObject.new(), block)
    @name = name
  end

  def assemble(memory)
    global_direvtive = ".global main"
    ([global_direvtive] + setup_asm_code(memory)).asm_join()
  end

  def bind_scope(scope)
  end
  
  def semantic_check()
  end

end
