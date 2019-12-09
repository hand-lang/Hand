require_relative 'utils/index'
require_relative 'std/index'
require_relative 'system/index'
require_relative 'config'


def dust(stmts) # dust vet att alla stmts är scopable och assemblabe
  main_fn  = HMainFunction.new("main", HBlock.new([HFunctionCall.new(stmts.last.name, HParamsWriterObject.new)]))
  print_param_symbol = 'print_param'
  
  print_str_fn = HPrintStringFunction.new(
              HParamsReaderObject.new([HParamReader.new(print_param_symbol, HStringType)]),
              HBlock.new([HIdentifier.new(print_param_symbol)])
            )
  print_int_fn = HPrintIntFunction.new(
              HParamsReaderObject.new([HParamReader.new(print_param_symbol, HIntegerType)]),
              HBlock.new([HIdentifier.new(print_param_symbol)])
            )


  stmts.push(main_fn)#insert(1, main)
  stmts.unshift(print_str_fn)
  stmts.unshift(print_int_fn)

  global_scope = Scope.new()
  stmts.each {|stmt| stmt.bind_scope(global_scope) }

  stmts.each {|stmt| stmt.semantic_check() }

  asm_code_array = stmts.reduce([]) {|asm, stmt| 
    asm.push(stmt.assemble(Memory.new))
  }

  data_section = HDataSectionWriter.shared.resolve()
  asm_code_array.unshift(data_section)

  code = asm_code_array.asm_join()

  return code
end