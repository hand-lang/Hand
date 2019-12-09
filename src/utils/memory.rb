class Memory
  attr_reader :offset

  def initialize()
    @offset       = -8
    @temp_offset  = -8
    @vars         = []
    @literal_pool = [] 
  end

  def next
    res = @offset
    @offset -= 4
    @temp_offset -= 4 # TODO vi måste ha någpn base
    return res.to_asm
  end

  def next_temp
    res = @temp_offset.to_asm
    @temp_offset -= 4
    return res
  end

  def read_temp
    return @temp_offset + 4
  end

  def read_perm
    return @offset
  end

  def clear_temp(count)
      bytes = count * 4
      @temp_offset = @temp_offset + bytes
  end

  def clear_perm(count)
     bytes = count * 4
     @offset = @offset + bytes
  end

  def add_variable(var)
    @vars.push(var)
  end

  def get_variable(symbol)
    return @vars.reverse.find { |variable_reader| variable_reader.symbol == symbol }
  end

  def add_to_pool(value, label = nil)
    label = label ? label : LabelGenerator.shared.generate_data_label
    # TODO don't add to pool if label exist with the same value
    @literal_pool.push(["#{label}:", ".word #{value}"].asm_join)
    return label
  end

  def resolve_pool()
    @literal_pool.asm_join
  end

  def reset_sp()
    return "add sp, fp, #-4"
  end

  def load(_offset, register)
    return "ldr #{register}, [fp, ##{_offset}]"
  end

  def store(register, _offset)
    return "str #{register}, [fp, ##{_offset}]"
  end


  def load_temp_to(register)
    return "ldr #{register}, [fp, #{read_temp.to_asm}]" 
  end

  def store_to_temp(register)
    return "str #{register}, [fp, #{next_temp}]"
  end

  def store_to_perm(register)
    return "str #{register}, [fp, #{self.next}]"
  end


end 