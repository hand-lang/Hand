# Hand, The language of the future
A compiler written in ruby, targets the 32-bit ARM architecture.

## To compile:
`ruby ./bin/hand.rb ./pseudo_project/in.hd --pi`

* `./pseudo_project/in.hd` should be the path to your code.
* `--pi` will push the code to the configured raspberry pi.
* `--no-optimize` skips the postprocessor of doing small assembly optimizations for the code.

## Configure the raspberry pi
The configuration has to be done manually for now, we have a *TODO* to automatize the process.  
* Go to `/src`
* Follow the instructions inside the `config.rb` file
