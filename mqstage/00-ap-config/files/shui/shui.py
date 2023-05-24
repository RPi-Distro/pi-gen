from sense_hat import SenseHat
from signal import pause
import subprocess
import time
import os
import signal
import shutil
import sh_utils

hat = SenseHat()
hat.clear()
page = 0
modes = [
          ("focus",            "F", lambda: killable_script(["python3", "-u", "/home/pi/shui/focus.py"], cwd="/home/pi"))
        , ("happy",            "H", lambda: killable_script(["python3", "-u", "/home/pi/shui/happy_snap.py"], cwd="/home/pi/happy_snaps", sleep=False))
        , ("stream",           "S", lambda: killable_script(["/home/pi/shui/stream.sh"], progress=True))
        , ("disk",             "D", lambda: killable_script(["python3", "-u", "/home/pi/shui/disk_used.py"]))
        , ("network details",  "N", lambda: killable_script(["/home/pi/shui/report_ssid.sh"], cwd="/home/pi/shui"))
        , ("refresh_ssid",     "R", lambda: killable_script(["/home/pi/shui/refresh_ssid.sh"], cwd="/home/pi/shui"))
        , ("join_local",       "J", lambda: killable_script(["python3", "-u", "/home/pi/shui/try_networks.py"], cwd="/home/pi/shui"))
        , ("force hotspot",    "A", lambda: killable_script(["/home/pi/shui/force_ap.sh"], cwd="/home/pi/shui"))
        , ("training_capture", "T", lambda: killable_script(["/home/pi/shui/capture.sh"], progress=True))
        , ("image_net",        "i", lambda: killable_script(["python3", "-u", "/home/pi/picam_predict/predict.py", "--model", "2", "--source", "1"], cwd="/home/pi/picam_predict"))
        , ("covered?",         "c", lambda: killable_script(["python3", "-u", "/home/pi/picam_predict/predict.py", "--model", "4", "--source", "1"], cwd="/home/pi/picam_predict"))
        , ("zero one",         "z", lambda: killable_script(["python3", "-u", "/home/pi/picam_predict/predict.py", "--model", "6", "--source", "1"], cwd="/home/pi/picam_predict"))
        , ("numbers?",         "n", lambda: killable_script(["python3", "-u", "/home/pi/picam_predict/predict.py", "--model", "7", "--source", "1"], cwd="/home/pi/picam_predict"))
        , ("glasses?",         "g", lambda: killable_script(["python3", "-u", "/home/pi/picam_predict/predict.py", "--model", "8", "--source", "1"], cwd="/home/pi/picam_predict"))
        ]
ps = None

print("hat initialised")

def menu():
    global page
    while True:
        # show the mode we are in
        hat.show_letter(modes[page][1])
        # show an indication of running short of disk space (less than 10MB)
        if (shutil.disk_usage("/").free < 10**7):
            hat.set_pixel(0,0,[255,0,0])
            hat.set_pixel(0,7,[255,0,0])
            hat.set_pixel(7,0,[255,0,0])
            hat.set_pixel(7,7,[255,0,0])
        event = hat.stick.wait_for_event()
        print(event)
        if (event.action != "pressed"):
            continue
        elif (event.direction == "right"):
            print("moving right " + str(page))
            page = (page + 1)% len(modes)
        elif (event.direction == "left"):
            print("moving left " + str(page))
            page = (page - 1)% len(modes)
        elif (event.direction == "middle"):
            print("pushing in " + str(page))
            modes[page][2]()

def killable_script(script, progress=False, cwd=None, sleep=True):
        ps = subprocess.Popen(script, cwd=cwd, preexec_fn=os.setsid)
        hat.clear()
        loops = 0
        while ps.poll() == None:
            # print the visualistaion of where we are up to
            loops = loops + 1
            if progress:
              sh_utils.pixels_of_num(loops)
            # wait a sec
            if sleep: 
              time.sleep(1)
            # check if we were interrupted
            for evt in hat.stick.get_events():
                print(evt)
                if (evt.direction == "middle" and evt.action == "pressed"):
                    print("got one to kill")
                    print(ps.pid) 
                    os.killpg(os.getpgid(ps.pid), signal.SIGTERM)
                    print("process killed")
                    ps = None
                    return
        ps = None
        return

        
menu()
