class Array

  def asm_join()
    self.compact!
    #self.push("\n")
    self.join("\n")
  end
  
end


class Integer
  def to_asm()
    return "##{self}"
  end
end