class Postprocessor

  def process(code)
    post_code = code
    post_code = code.gsub(/str (r\d), (\[fp, #-\d*\])[ ]*\nldr \1, \2/, '') #OPTIMIZATION 1


    result = post_code.scan(/(str (r\d), \[fp, #(-\d+)\][ ]*\n((?:(?:ldr|str)) (?!\2).*\n)*ldr \2, \[fp, #\3\][ ]*\n)/) #OPTIM 2
    
    result.each {|match|
      post_code.sub!(match[0], match[3])
    }

    result = post_code.scan(/(str (r3), \[fp, #(-\d+)\][ ]*\n((?:(?:ldr)) r3.*\n)ldr r4, \[fp, #\3\][ ]*\n)/)
    result.each {|match|
      post_code.sub!(match[0], "mov r4, r3\n" + match[3])
    }
    

    return post_code
  end

end