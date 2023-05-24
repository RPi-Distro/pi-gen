import picamera
from picamera.array import PiRGBArray
import cv2
from sense_hat import SenseHat
import math

cam = picamera.PiCamera()
hat = SenseHat()

while True:
    raw = PiRGBArray(cam)
    cam.capture(raw, format="bgr")
    gray = cv2.cvtColor(raw.array, cv2.COLOR_BGR2GRAY)
    h = len(gray)
    w = len(gray[0])
    hs = h//8
    ws = w//8
    for x in range(8):
        for y in range(8):
            sub = gray[y*hs:(y+1)*hs, x*ws:(x+1)*ws]
            v = cv2.Laplacian(sub, cv2.CV_64F).var()
            i = max(min(math.floor(v/4), 255), 0)
            hat.set_pixel(x,y,[i, i, i])
