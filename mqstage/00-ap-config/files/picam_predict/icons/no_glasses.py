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
    o,r,o,o,o,o,r,o,
    o,o,r,o,o,r,o,o,
    b,b,b,r,r,b,b,b,
    o,b,b,r,r,b,b,o,
    o,o,r,o,o,r,o,o,
    o,r,o,o,o,o,r,o,
    o,o,o,o,o,o,o,o,
    ])

