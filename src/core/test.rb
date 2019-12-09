# coding: utf-8

=begin
module Debug
  def whoAmI?
    "AOAAÀPOOAOOAOAO"
  end
end
class Phonograph
  include Debug
  # ...
end
class EightTrack
  include Debug
  def whoAmI?
    return "I am your father" + " noooooooooooo"
  end
end
ph = Phonograph.new()
et = EightTrack.new()
puts et.whoAmI?
puts ph.whoAmI?
=end


=begin
class LabelGenerator
  def initialize()
    @literal_counter  = 0
    @statment_counter = 0
  end

  def self.shared()
    return @instace if @instace
    @instace = LabelGenerator.new
  end

  def generate_data_label
    @literal_counter += 1
    return ".LD#{@literal_counter}:" 
  end

  def generate_statement_label
    @statment_counter += 1
    return ".LS#{@statment_counter}:"
  end

end

a = LabelGenerator.shared

puts a.generate_data_label
puts a.generate_statement_label

b = LabelGenerator.shared

puts b.generate_data_label
puts b.generate_statement_label

c = LabelGenerator.shared

puts c.generate_data_label
puts c.generate_data_label
puts c.generate_statement_label


=end

#for i in (1...2)
#	puts "aoa"
#end




#puts ARGV

