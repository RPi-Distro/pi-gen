from sense_hat import SenseHat
import subprocess

times = 3
while (times > 0):
  hat = SenseHat()
  ssid = subprocess.run(["sudo grep -w ssid /etc/NetworkManager/system-connections/WiFiAP.nmconnection | sed 's!^ssid=!!'"], shell=True, stdout=subprocess.PIPE)
  hat.show_message(ssid.stdout.decode("utf-8"))
  times = times - 1

hat.clear()
