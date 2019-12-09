
def push_to_pi(file_name)
    #put these in `~/.ssh/config` file
  
=begin
    Host 213.89.59.20
      IdentityFile ~/Desktop/pi_stuff/apa_rsa
      PubKeyAuthentication yes
=end
  
    # IdentiyFile replaced with your destination to apa.rsa
    # apa.rsa should have mod 600
    # apa.rsa should be added
    # ssh agent should be evaluated
  
    ip = '213.89.59.20'
    system "scp -P 80 #{file_name} pi@#{ip}:stuff/hand/"
  
end

$config = {
    'kenan' => { 
        'output_path' => '/home/kenan/Documents/TDP019/parser/output/code.s',
        'input_path'  => '/home/kenan/Documents/TDP019/parser/input/in.hd',
    },

    'basel' => {
        'output_path' => '/home/basns594/Desktop/TDP019/parser/output/code.s',
        'input_path'  => '/home/basns594/Desktop/TDP019/parser/input/in.hd',
        'preprocessor_output_path' => '/home/basns594/Desktop/TDP019/parser/input/in.hd'
    },

    'basel_mac' => {
        
        'output_path' => '/Users/fdsfasddsfsdff/Desktop/TDP019/parser/output/code.s',
        'input_path'  => '/Users/fdsfasddsfsdff/Desktop/TDP019/parser/input/in.hd',
        'preprocessor_output_path' => '/Users/fdsfasddsfsdff/Desktop/TDP019/parser/input/in.hd'
    }
}

def config()
    conf = $config['basel']
    $config = conf
    return conf
end

config()