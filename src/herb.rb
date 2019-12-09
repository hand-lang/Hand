# coding: utf-8
require_relative 'rdparse'
require_relative 'dust'
require_relative 'utils/index'
require_relative 'core/index'
require_relative 'config'
require_relative 'string_literal.rb'
require_relative 'preprocessor'

class Herb
  
  def initialize
    @parser = Parser.new("Herb") do

      token(/\s+/)
      token(/\/\/.*$/)
      token(/\/\*(?:.|\s)*\*\//)

      token(/\"([^\"]*)\"/) {|literal| StringLiteral.new(literal) }

      token(/\d+/)          {|m| m }
      token(/[a-zA-Z_]+/)   {|m| m }
      token(/[<>=&\|!]{2}/) {|m| m } 
      #token(/>>/)  {|m| m } 
      #token(/==/)   {|m| m }
      #token(/(<=|>=)/)
      token(/./) {|m| m}

      start :program do 
        match(:function_definition, :function_definitions) {|a, b|
          stmts = b.unshift(a)
          stmts
        }

        match(:start_function_definition, :function_definitions) {|a, b|
          stmts = b.push(a)
          stmts
        }
      end
      
      rule :function_definitions do
        match(:function_definition, :function_definitions) {|a, b| b.unshift(a) }
        match(:start_function_definition, :function_definitions) {|a, b| b.push(a) }
        match(:empty) {|_| [] }
      end

      rule :stmts do 
        match(:stmt, :stmts) {|a, b| b.unshift(a) }
        match(:empty) {|_| [] }
      end

      rule :stmt do
        match(:function_definition) {|f| f}
        match(:conditional) {|c| c}
        match(:loop) {|c| c}
        match(:expr_line, :end) {|m, _| m}
      end
   
      rule :conditional do
        match('if', :conditional_body, :compound, :conditional_compliment) {|_, cb, c, cc|
          HIf.new(cb, c, cc)
        }
      end

      rule :loop do
        match('while', :conditional_body, :compound) {|_, cb, c|
          HLoop.new(cb, c)
        }
      end

      
      rule :conditional_body do
        match('(', :expr_part, ')') {|_, e, _| e}
        match(:expr_part) {|e| e}
      end

      rule :conditional_compliment do
        # match('else', :conditional) TODO: ELSE IF
        match('else', :compound) {|_, c| c }
        match('else', 'if', :elseif_block) {|_,_, c| c }
        match(:empty) {|_| HBlock.new([])}
      end

      rule :elseif_block do
        match(:conditional_body, :compound, :conditional_compliment) {|cb, c, cc| HBlock.new([HIf.new(cb, c, cc)]) }
      end

      rule :expr_line do
        match(:expr) {|a| a} 
      end
      
      rule :expr do
        match(:return)     {|a| a } # tillfälligt
        match(:func_call)  {|a| a } 
        match(:assignment) {|a| a } #puts @variables} #puts skapar problem med rdparse.rb
      end
      
      rule :return do
        match("return", :expr_part) {|_, value| HReturn.new(value) }
      end

      rule :assignment do
        match('@', :word, "=", :expr_part) {|a, b, _, c| 
         HAssignment.new(b, c) # HVar, HProcedure
        }
        
        match(:word, "=", :expr_part) {|w, _, part| HReassignment.new(w, part) } # TODO: Skapa en class för det här, needs semantic bind_scopes
      end
      
      rule :expr_part do
        match(:logical) {|a| a}
      end
      
      rule :logical do
        match(:logical, :log_op, :log_fac) {|a, logical_object, c| logical_object.new(a, c)} 
        match(:log_fac) {|a| a}
      end
      
      rule :log_fac do
        match(:comparison) {|a| a}
      end
      
      rule :log_op do # till exempel så kommer denna operator skapa klassen med && evaluaerin
        match("&&") {|a| HLog_And}
        match("||") {|a| HLog_Or}
        match("!")  {|a| HLog_Not}
      end
      
      rule :comparison do
        match(:comparison, :comp_op, :comp_fac) {|a, comparison_object, c| comparison_object.new(a, c)} 
        match(:comp_fac) {|a| a}
      end
      
      rule :comp_fac do
        match(:arithmetic) {|a| a}
      end

     rule :comp_op do
        match("!=") {|a| HComp_NE}
        match("==") {|a| HComp_EE}
        match("<=") {|a| HComp_LE}
        match(">=") {|a| HComp_GE}
        match("<")  {|a| HComp_L}
        match(">")  {|a| HComp_G}
      end
      
      rule :arithmetic do
        match(:term) {|a| a}
      end

      rule :term do
        match(:term, "+", :product) {|a, _, b|  HAdd.new(a, b) }
        match(:term, "-", :product) {|a, _, b|  HSub.new(a,b)  }
        match(:product) {|a| a}
      end

      rule :product do
        match(:product, "*", :factor) {|a, _, b| HMul.new(a, b) }
        match(:product, "/", :factor) {|a, _, b| HDiv.new(a, b) }
        match(:product, "%", :factor) {|a, _, b| HSub.new(a, HMul.new(HDiv.new(a, b), b)) }
        match(:factor) {|a| a}
      end

      rule :factor do
        match(:func_call)            {|a| a }
        match(:word) {|a| HIdentifier.new(a) } # access kommer asseblas till att den storar i en nextTemp
        match("(", :expr_part, ")")  {|_, a, _| a}
        #match("(", :assignment, ")") {|_, a, _| a}
        match(:literal_string)       {|a| HLiteral.new(HStringType.new(a))  }
        match(:number)               {|a| HLiteral.new(HIntegerType.new(a)) }
        match(:signed_number)        {|a| HLiteral.new(HIntegerType.new(a)) }
        #match(:access) {|a| a}
      end

      # =================== FUNCTIONS =============

      rule :function_definition do
        match('@', :word, '(', :optional_read_params, ')', :compound) {|_, w, _, op, _, c| HFunction.new(w, op, c)}
      end

      rule :start_function_definition do
        match('>>', '@', :word, '(', ')', :compound) {|_, _, _, _, _, c| HInitialFunction.new(c) }
      end

      rule :func_call do
        match(:word, "(", :optional_write_params, ")") {|w, _, op, _| HFunctionCall.new(w, op) }
      end

      rule :optional_write_params do
        match(:write_params) {|p| HParamsWriterObject.new(p) } # handle function object creation
        match(:empty)        {|_| HParamsWriterObject.new([]) } # EMPTY
      end
      
      rule :write_params do
         match(:expr_part, :write_params_d) {|a, b| [HParamWriter.new(a)] + b } 
      end

      rule :write_params_d do
        match(",", :write_params) {|_, a| a}
        match(:empty) {|_| [] }
      end

      rule :optional_read_params do
        match(:read_params) {|p| HParamsReaderObject.new(p) } # handle function object creation
        match(:empty)       {|_| HParamsReaderObject.new([])} # EMPTY
      end
      
      rule :read_params do
         match(:word, :read_params_d) {|a, b| [HParamReader.new(a)] + b } 
      end

      rule :read_params_d do
        match(",", :read_params) {|_, a| a}
        match(:empty) {|_| [] }
      end




      # =================== FUNCTION CALL END =============

      #============= SHARED ==============================

      rule :compound do
        match('{', :stmts, '}') {|_, stmts, _| HBlock.new(stmts)}
      end

      rule :signed_number do
        match("+", :number) {|_, n| n    }
        match("-", :number) {|_, n| -1*n }
      end

      rule :number do
        match("0") {|m| m.to_i}
        match(/[1-9]/, :digits) {|a, b| (a+b).to_i }
      end

      # ==== DIGITS =====
      rule :digits do
        match(:digit, :digits) { |a, b| (a+b).to_i }
        match(:empty) {|e| "" }
      end

      rule :digit do
        match(/[0-9]/)
      end
      # ==== DIGITS END =====

      rule :literal_string do
        match(StringLiteral) {|str| str.value}
      end

      rule :type do
        match(:word) {|m| m}
      end

      rule :word do
        match(/[a-zA-Z_]+/){|w| w} # TODO: tillåt siffror i mitten
      end

      rule :end do
        match(";")
      end
      #=============== SHARED END =============================

    end
  end
  
  def process(code)
    #file = File.new($config['input_path'], 'r')
    #code = in_code#file.readlines.join('')
    function_list = @parser.parse(code)
    return function_list

  end

  def log(state = true)
    if state
      @parser.logger.level = Logger::DEBUG
    else
      @parser.logger.level = Logger::WARN
    end
  end
end
