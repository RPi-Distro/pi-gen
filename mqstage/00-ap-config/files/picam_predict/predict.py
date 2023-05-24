import argparse
import subprocess
import tflite_runtime.interpreter as tflite
import numpy as np
from PIL import Image
import time
import shutil
import os
import glob
import picamera
from sense_hat import SenseHat
from datetime import datetime

try:
  cam = picamera.PiCamera()
  cam.resolution = (224,224)
  cam.rotation = 90
except:
  print("no camera detected")
  cam = None

def feed(lst_globs):
  if lst_globs == "":
    while True:
      cam.capture("images/camera-feed.jpg")
      yield "images/camera-feed.jpg"
  else:
    for img_glob in sources[src_i][1]:
      for img_path in glob.glob(img_glob):
        yield img_path

argparser = argparse.ArgumentParser(description="Run a Model on a set of images or a camera feed and generate predictions.")
argparser.add_argument("--model", metavar="M", type=int, help="the index of the model to use.")
argparser.add_argument("--source", metavar="S", type=int, help="the index of the source to use.")
argparser.add_argument("--dir", metavar="d", help="define the model directory directly")
args = argparser.parse_args()

models = [("MobileNet V1 224","models/mobilenet_v1_1.0_224_quant"),
          ("MobileNet V1 128","models/mobilenet_v1_0.25_128_quant"),
          ("MobileNet V3 224 float", "models/mobilenet_v3_224_float"),
          ("Inception V4", "models/inception_v4_quant"),
          ("Custom: Is the camera covered (quant)?", "models/covered_quant"),
          ("Custom: Is the camera covered (float)?", "models/covered_float"),
          ("Custom: Numbers 0 or 1", "models/Zero_One_Model01"),
          ("Custom: Numbers 0 to 5", "models/Zero_Five_Model03"),
          ("Custom: Glasses or not glasses?", "models/glasses_or_not")
         ]

sources = [("Example Images",["images/224x224/*",
                              "images/room.jpg", 
                              "images/239x215/*", 
                              "images/128x128/*",
                              "images/imagenet_examples/*",
                              "images/faces/*"
                              ]),
           ("Camera","")
          ]

hat = SenseHat()
hat.show_letter("?", [255,255,255],[0,0,0])

if args.model is None:
  print("Which model would you like to run?")
  for i, mod in enumerate(models):
    print(f"({i}) {mod[0]}")
  model_i = int(input())
else:
  model_i = args.model

if args.source is None:
  print("Which source would you like predict from?")
  for i, src in enumerate(sources):
    print(f"({i}) {src[0]}")
  src_i = int(input())
else:
  src_i = args.source

hat.show_letter(str(model_i), [255,255,255], [0,0,0])

interpreter = tflite.Interpreter(models[model_i][1]+"/model.tflite")
interpreter.allocate_tensors()

inputs = interpreter.get_input_details()[0];
outputs = interpreter.get_output_details()[0];
width  = inputs["shape"][2]
height = inputs["shape"][1]
dtype = inputs["dtype"]
scale, zero = outputs['quantization']
print(f"Predicting with model:  {models[model_i][0]}\n  * size: ({width}x{height})\n  * type: {dtype}\n  * scale: ({scale},{zero})")

lables=[]
with open(models[model_i][1]+"/labels.txt", "r") as f:
    labels = [line.strip() for line in f.readlines()]

icons=[]
try:
    with open(models[model_i][1]+"/icons.txt", "r") as f:
        icons = [line.strip() for line in f.readlines()]
except:
    print("no icon file found")

log_as=[]
try:
    with open(models[model_i][1]+"/log_as.txt", "r") as f:
        log_as = [line.strip() for line in f.readlines()]
except:
    print("no logging file found")

print(f"Predicting from source: {sources[src_i][0]}")

hat.clear()

for img_path in feed(sources[src_i][1]):
  img = Image.open(img_path).convert('RGB').resize((width, height))
  
  # we need another dimension
  input_data = np.expand_dims(img, axis=0)
  # TODO: hard coding the std for float32 models - but seems to work for now
  if (dtype == np.float32):
      input_data = np.float32(input_data)/255

  # lets get to it
  interpreter.set_tensor(inputs["index"], input_data)

  interpreter.invoke()

  output_data = interpreter.get_tensor(outputs["index"]).squeeze()
  if (scale > 0): # TODO: this line scales and converts to percentage, so we need an else.  Might be better to do percentage in the display line
      output_data = (scale*100) * (output_data - zero)
  else:
      output_data = 100 * output_data

  ordered_indexes = np.flip(output_data.argsort())
  best_index = ordered_indexes[0]

  # display on sense_hat
  icon_file = icons[best_index] if len(icons) > best_index else None
  if (icon_file):
      exec(open(f"icons/{icon_file}.py").read())
  else:
      exec(open(f"icons/number.py").read() + f"\npixels_of_num({best_index})\n")

  # log if needed
  log_as_file = "/home/pi/logs/" + models[model_i][1] + "/" + log_as[best_index]+"/" + datetime.now().strftime("%Y-%m-%d:%H:%M:%S")+".png" if len(log_as) > best_index else None
  if (log_as_file):
      os.makedirs(os.path.dirname(log_as_file), exist_ok=True)
      shutil.copy(img_path, log_as_file)

  print(f"  * {img_path} = {labels[best_index]} %0.0f%%" % output_data[best_index])
