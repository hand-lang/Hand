#!/usr/bin/env ruby

require_relative '../src/herb'
require_relative '../src/preprocessor'
require_relative '../src/config'
require_relative '../src/dust'
require_relative '../src/postprocessor'

input_file   = ARGV[0]
out_file     = './code.s'

input_file_working_directory = File.dirname(input_file)

preprocessor  = Preprocessor.new(input_file_working_directory)
herb          = Herb.new
postprocessor = Postprocessor.new

preprocessor.log(false)
herb.log(false)

input_code    =  File.new(input_file, 'r').readlines.join('')


puts "Preprocessing..."
preprocessed_code  = preprocessor.process(input_code)

puts "Parsing..."
intermediate_code  = herb.process(preprocessed_code)

puts "Generating code..."
assembly_code      = dust(intermediate_code)

if not ARGV.include?("--no-optimize")
  puts "Postprocessing..."
  postprocessed_code = postprocessor.process(assembly_code)
else
  postprocessed_code = assembly_code
end

file      = File.open("./#{out_file}", "w")
file.sync = true
file.puts postprocessed_code

if ARGV.include?("--pi")
  puts "Pushing to pi..."
  push_to_pi(out_file)
end

puts "Compiled successfully!"