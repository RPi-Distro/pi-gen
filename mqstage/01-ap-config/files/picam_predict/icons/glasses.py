from sense_hat import SenseHat

hat = SenseHat()

o = [0,0,0]
w = [250,250,250]
g = [0,100,0]
r = [100,0,0]
b = [0,0,100]
s = [80,80,80]

hat.set_pixels([
    o,o,o,o,o,o,o,o,
    o,o,o,o,o,o,o,o,
    o,o,b,o,o,b,o,o,
    b,b,b,b,b,b,b,b,
    o,b,b,b,b,b,b,o,
    o,o,b,o,o,b,o,o,
    o,o,o,o,o,o,o,o,
    o,o,o,o,o,o,o,o,
   ])
