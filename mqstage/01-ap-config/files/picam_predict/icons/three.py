from sense_hat import SenseHat

o = [0,0,0]
w = [250,250,250]
g = [0,100,0]
r = [100,0,0]
b = [0,0,100]
s = [80,80,80]
c = g

hat = SenseHat()

hat.set_pixels([
        o,o,o,o,o,o,o,o,
        o,o,c,c,c,c,o,o,
        o,o,o,o,c,o,o,o,
        o,o,o,c,o,o,o,o,
        o,o,o,o,c,o,o,o,
        o,o,o,o,o,c,o,o,
        o,o,c,c,c,o,o,o,
        o,o,o,o,o,o,o,o
        ])
