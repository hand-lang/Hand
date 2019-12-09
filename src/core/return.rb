class HReturn < HandObject
  def initialize(value = nil)
    @value = value
  end
  
  def assemble(memory)
    ret_val = nil
    load_ret_val = nil
   
    if @value
      ret_val      = @value.assemble(memory)
      load_ret_val = "ldr r0, [fp, #{memory.read_temp.to_asm}]"
    end

    get_link     = "pop  {fp, lr}"
    return_inst  = "bx lr"
    reset_sp     = memory.reset_sp()

    return [ret_val, load_ret_val, reset_sp, get_link, return_inst].asm_join()
  end

  def bind_scope(scope)
    @value.bind_scope(scope)
  end

  def get_type()
    HVoidType unless @value
    @value.get_type()
  end

end
