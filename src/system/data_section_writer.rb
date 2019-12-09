
require_relative "../utils/index"
require_relative "label_generator"

class HDataSectionWriter
  attr_reader :collection
  
  def initialize()
    @collection = [".data\n"]
    @type_hash = {
      HIntegerType => "%d", #TODO \n är för noobs
      HStringType  => "%s"  #TODO \n är för noobs
    }
    @type_store = {}
  end
  
  def resolve
    return [@collection.asm_join, ".text"].asm_join
  end
  
  
  def self.shared()
    return @instance if @instance
    @instance = HDataSectionWriter.new
  end
  
  
  def store(content, label = nil)
    label = label ? label : LabelGenerator.shared.generate_data_label()
    @collection.push(["#{label}:", ".asciz \"#{content}\""].asm_join)
    return label
  end
  
  def store_type_identifier(type)
    return @type_store[type] if @type_store[type]
    label = LabelGenerator.shared.generate_data_label()
    store(@type_hash[type], label)
    @type_store[label] = type
    return label
  end


  private :initialize
end

