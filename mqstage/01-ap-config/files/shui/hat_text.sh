#!/bin/python3

from sense_hat import SenseHat
import sys

hat = SenseHat()
hat.show_message(sys.argv[1])
