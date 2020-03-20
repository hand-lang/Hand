# Hand, The language of the future
A compiler written in ruby, targets the 32-bit ARM architecture.

## To compile:
`ruby ./bin/hand.rb ./pseudo_project/in.hd --pi`

`./pseudo_project/in.hd` should be the path to your code.
`--pi` will push the code to the configured raspberry pi.
`--no-optimize` skips the postprocessor fixing your bad code.

## Configure the raspberry pi
* Go to /
