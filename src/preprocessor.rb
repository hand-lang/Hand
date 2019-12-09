require_relative 'rdparse'
require_relative 'config'
require_relative 'string_literal.rb'

class Array
    def macro_match(text)
        macro_obj = self.find {|macro| macro.value == text }
        result    = macro_obj ? macro_obj.replace : text
        return result
    end
end

class IncludeMacro 
    attr_reader :value
    def initialize(file_src, directory)
        file = File.open("#{directory}/#{file_src}", "r")
        file.sync = true
        @value = file.read
    end
end

class DefineMacro
    attr_reader :value, :replace
    def initialize(value, repalce)
        @value = value
        @replace = repalce 
    end
end

class Preprocessor
    
    def initialize(directory)
      @preprocessor = Parser.new("HAND Preprocessor") do
        macros = []
        token(/#include\s*<([^ ]+)>\s*$/)  {|file| IncludeMacro.new(file, directory) }
        token(/#define\s+([^ ]+)\s+(.+)$/) {|value, replace| 
            def_macro = DefineMacro.new(value, replace)
            macros.push(def_macro) 
            def_macro
        }
        token(/\s+/)          {|s| s}
        token(/\"([^\"]*)\"/) {|literal| StringLiteral.new(literal) }
        token(/\w+/)          {|m| m }
        token(/./)            {|m| m }

        start :program do 
          match(:word, :words) {|word, word_arr| 
          
          word_arr.unshift(word)
          text = word_arr.join() 
          text
        }
        end
        
        rule :word do 
            match(:macro)        {|macro|   macro}
            match(StringLiteral) {|literal| literal.quoted }
            match(/\w+/)         {|text|    macros.macro_match(text) }
            match(/.*/)          {|chars|   chars }
        end
  
        rule :words do
            match(:word, :words) {|a, b| b.unshift(a)}
            match(:empty) {|_| []}
        end

        rule :macro do
          match(IncludeMacro) {|include_macro| 
            include_macro.value
          }

          match(DefineMacro) {|define_macro|
             result = ''
             result
          }
        end
      end
    end
    
    def process(code)

        result = @preprocessor.parse(code)
        return result
        #preprocessd_file = './preprocessed_file'
        #file   = File.open(preprocessd_file, "w")
        #file.sync = true
        #file.puts result
        #return result
    end

    def log(state = true)
        if state
          @preprocessor.logger.level = Logger::DEBUG
        else
          @preprocessor.logger.level = Logger::WARN
        end
    end

  end
