import io
import picamera
from PIL import Image
from sense_hat import SenseHat
from datetime import datetime

cam = picamera.PiCamera()
cam.start_preview()
cam.rotation = 90
hat = SenseHat()
hat.low_light = False

while True:
    print(".", end="", flush=True)
    stream = io.BytesIO()
    cam.capture(stream, format='jpeg')
    stream.seek(0)
    image = Image.open(stream)
    pixel_img = image.resize((8,8))
    for x in range(0,8):
      for y in range(0,8):
          hat.set_pixel(x,y, pixel_img.getpixel((x,y)))
    for evt in hat.stick.get_events():
        if (evt.direction == "middle" and evt.action == "pressed"):
            exit()
        if (evt.direction == "up" and evt.action == "pressed"):
            label = datetime.now().strftime("%Y-%m-%d:%H:%M:%S")
            image.save(label+".png", "PNG")
            pixel_img.save(label+".tiny.png", "PNG")
