require_relative '../utils/index'
require_relative 'type'

class HBlock < HandObject
  attr_reader :stmts, :returning

  def initialize(stmts)
    @stmts = stmts
    @returning = false
  end

  def assemble(memory)
    stmts_txt = @stmts.reduce([]) {|acc, stmt|
      @returning = stmt.class == HReturn ? true : @returning
      acc.push(stmt.assemble(memory))
    }
    stmts_txt.asm_join()
  end

  def bind_scope(scope)
    stmts.each {|stmt| stmt.bind_scope(scope) }
  end 

  def get_type()
    return_stmt = @stmts.find {|stmt| stmt.class == HReturn }
    return HVoidType unless return_stmt
    return_stmt.get_type()
    # HRETURN TYPE
  end

  def semantic_check()
    stmts.each {|stmt| stmt.semantic_check() }
  end

end