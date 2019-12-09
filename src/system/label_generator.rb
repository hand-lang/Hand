
class LabelGenerator
private
  def initialize()
    @literal_counter  = 0
    @statment_counter = 0
  end

public
  def self.shared()
    return @instace if @instace
    @instace = LabelGenerator.new
  end

  def generate_data_label
    @literal_counter += 1
    return "LD#{@literal_counter}" 
  end

  def generate_statement_label
    @statment_counter += 1
    return "LS#{@statment_counter}"
  end

end