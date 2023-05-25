import shutil
import sh_utils
import time

while True:
    total, used, free  = shutil.disk_usage("/")
    percentage = used / total
    pixels = int(percentage * 60)
    print(f"{percentage*100:2.2f}% of disk used")
    sh_utils.pixels_of_num(pixels)
    time.sleep(10)
