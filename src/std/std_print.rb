require_relative '../core/index'
require_relative '../system/index'

class HPrintFunction < HFunction

  def initialize(name, params_object, block)
    super(name, params_object, block)
  end

  def assemble(memory)
    read_params       = @paramsObject.assemble(memory)
    start_label       = "#{@name}:"
    save_link         = "push {fp, lr}"
    val_type          = @paramsObject.get(1).get_type()
    label             = HDataSectionWriter.shared.store_type_identifier(val_type)
    load_type         = "ldr r0, =#{label}"
    store_val_to_temp = @block.assemble(memory)
    load_inst         = memory.load_temp_to("r1")
    printf_call       = "bl printf"
    return_inst       = @block.returning ? nil : HReturn.new.assemble(memory)
    fp_position       = "add fp, sp, #4" # här är felet från main, fp_position nya är det här
    sp_position       = "add sp, sp, #{(memory.read_temp-4).to_asm}" # TODO: Ska det var temp här ?
    [start_label, save_link, fp_position, sp_position, load_type, store_val_to_temp, load_inst, printf_call, return_inst, memory.resolve_pool].asm_join()
  end

  def bind_scope(scope) # Lägg till sig själv i scopet
    raise DuplicateDefinitionError.new(@name) if scope.in_scope(@name)
    #scope.add_to_scope(@name[1..-1])
    scope_obj = ScopeObject.new(@name, HFunctionType, @paramsObject.type_list)
    scope.add_to_scope(scope_obj)
    scope.add_scope
    @paramsObject.bind_scope(scope)
    @block.bind_scope(scope)
    scope.remove_last
  end

end


class HPrintStringFunction < HPrintFunction
  def initialize(params_object, block)
    super("pring", params_object, block)
  end
end

class HPrintIntFunction < HPrintFunction
  def initialize(params_object, block)
    super("print", params_object, block)
  end
end