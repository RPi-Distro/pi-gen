from sense_hat import SenseHat

hat = SenseHat()

def pixels_of_num(pixels):
    hat.set_pixels(pon(pixels))

def pon(remaining):
    limit = 64
    at = 0
    pixels = [[0,0,0]]*64
    while remaining > 0:
        if (remaining > limit):
            pixels[at] = [255,0,0]
            at = at + 1
            limit = limit -1
            remaining = remaining - limit
        else:
            pixels[at] = [255,255,255]
            remaining = remaining -1
            at = at + 1
    return pixels


