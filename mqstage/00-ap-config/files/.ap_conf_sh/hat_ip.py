from sense_hat import SenseHat
import subprocess

times = 3
while (times > 0):
  hat = SenseHat()
  address = subprocess.run(["hostname", "-I"], stdout=subprocess.PIPE)
  hat.show_message(address.stdout.decode("utf-8"))
  times = times - 1

hat.clear()
