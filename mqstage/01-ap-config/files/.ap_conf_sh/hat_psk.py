from sense_hat import SenseHat
import subprocess

times = 3
while (times > 0):
  hat = SenseHat()
  psk = subprocess.run(["sudo grep ^psk /etc/NetworkManager/system-connections/WiFiAP.nmconnection | sed 's!^psk=!!'"], shell=True, stdout=subprocess.PIPE)
  hat.show_message(psk.stdout.decode("utf-8"))
  times = times - 1

hat.clear()
