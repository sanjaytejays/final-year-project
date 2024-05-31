#!/usr/bin/env python

import cv2
import os
import sys, getopt
import signal
import time
from edge_impulse_linux.image import ImageImpulseRunner

import RPi.GPIO as GPIO 
from hx711 import HX711

import requests
import json
from requests.structures import CaseInsensitiveDict
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("final-year-project-4a9e1-firebase-adminsdk-q4uyv-c111fae6c7.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

runner = None
show_camera = True

c_value = 0
flag = 0
ratio = -1363.992

id_product = 1
list_label = []
list_weight = []
count = 0
final_weight = 0
taken = 0

c = 'snickers'
o = 'orange'
s = 'sauce'

def now():
    return round(time.time() * 1000)

def get_webcams():
    port_ids = []
    for port in range(5):
        print("Looking for a camera in port %s:" %port)
        camera = cv2.VideoCapture(port)
        if camera.isOpened():
            ret = camera.read()[0]
            if ret:
                backendName =camera.getBackendName()
                w = camera.get(3)
                h = camera.get(4)
                print("Camera %s (%s x %s) found in port %s " %(backendName,h,w, port))
                port_ids.append(port)
                print('camera is found')
            camera.release()
    return port_ids

def sigint_handler(sig, frame):
    print('Interrupted')
    if (runner):
        runner.stop()
    sys.exit(0)

signal.signal(signal.SIGINT, sigint_handler)

def help():
    print('python classify.py <path_to_model.eim> <Camera port ID, only required when more than 1 camera is present>')

def find_weight():
    global c_value
    global hx
    if c_value == 0:
        print('Calibration starts')
        try:
          GPIO.setmode(GPIO.BCM)
          hx = HX711(dout_pin=5, pd_sck_pin=6)
          err = hx.zero()
          if err:
            raise ValueError('hx zero func is unsuccessful.')
          hx.set_scale_ratio(ratio)
          c_value = 1
        except (KeyboardInterrupt, SystemExit):
          print('Bye :)')
        print('Calibrate ends')	
    else :
          GPIO.setmode(GPIO.BCM)
          time.sleep(1)
          try:
                weight1 = abs(int(hx.get_weight_mean(20))) 
                weight= weight1 - 245              #round(weight,1)
                print(weight + 263, 'g')
                return weight 
          except (KeyboardInterrupt, SystemExit):
                print('Bye :)')
               
def post(label,price,final_rate,taken):
    global id
    url = "https://final-year-project-jnik.onrender.com/product"
    headers = CaseInsensitiveDict()
    id_product=1
    headers["Content-Type"] = "application/json"
    data_dict = {"id":id_product,"name":label,"price":price,"units":"units","taken":taken,"payable":final_rate}
    data = json.dumps(data_dict)
    resp = requests.post(url, headers=headers, data=data)
    print(resp.status_code)
    id_product = id_product + 1  
    time.sleep(1)
    list_label = []
    list_weight = []
    count = 0
    final_weight = 0
    taken = 0
    try:
        doc_ref = db.collection('items').document()
        doc_ref.set(data_dict)
        print('dicument added with:', doc_ref.id)
    except Exception as e:
        print('error adding data', str(e))
                
def list_com(label,final_weight):
    global count
    global taken
    if final_weight > 2 :	
       list_weight.append(final_weight)
       if count > 1 and list_weight[-1] > list_weight[-2]:
           taken = taken + 1
    list_label.append(label)
    count = count + 1
    print('count is',count)
    time.sleep(1)
    if count > 1:
        print('This is list label',list_label)
        print('This is list weight',list_weight)
        if list_label[-1] != list_label[-2] :
           print("New Item detected")
           print("Final weight is",list_weight[-1])
           rate(list_weight[-2],list_label[-2],taken)          
	
def rate(final_weight,label,taken):
    print("Calculating rate")
    print('final weight',final_weight,'labels',label,'taken',taken)
    if label == o :
         print("Calculating rate of",label)
         final_rate_a = final_weight * 0.119  
         price = final_rate_a     
         post(label,price,final_rate_a,taken)
    elif label == c:
         print("Calculating rate of",label)
         final_rate_l = 10
         price = 10
         post(label,price,final_rate_l,taken)
    elif label == s:
         print("Calculating rate of",label)
         final_rate_l = 5
         price = 5
         post(label,price,final_rate_l,taken)
    else :
         print("No item detected")
def main(argv):
    global flag
    global final_weight
    if flag == 0 :
        find_weight()
        flag = 1      
    try:
        opts, args = getopt.getopt(argv, "h", ["--help"])
    except getopt.GetoptError:
        help()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            help()
            sys.exit()

    if len(args) == 0:
        help()
        sys.exit(2)

    model = args[0]

    dir_path = os.path.dirname(os.path.realpath(__file__))
    modelfile = os.path.join(dir_path, model)

    print('MODEL: ' + modelfile)

    with ImageImpulseRunner(modelfile) as runner:
        try:
            model_info = runner.init()
            print('Loaded runner for "' + model_info['project']['owner'] + ' / ' + model_info['project']['name'] + '"')
            labels = model_info['model_parameters']['labels']
            if len(args)>= 2:
                videoCaptureDeviceId = int(args[1])
            else:
                port_ids = get_webcams()
                if len(port_ids) == 0:
                    raise Exception('Cannot find any webcams')
                if len(args)<= 1 and len(port_ids)> 1:
                    raise Exception("Multiple cameras found. Add the camera port ID as a second argument to use to this script")
                videoCaptureDeviceId = int(port_ids[0])

            camera = cv2.VideoCapture(videoCaptureDeviceId)
            ret = camera.read()[0]
            if ret:
                backendName = camera.getBackendName()
                w = camera.get(3)
                h = camera.get(4)
                print("Camera %s (%s x %s) in port %s selected." %(backendName,h,w, videoCaptureDeviceId))
                camera.release()
            else:
                raise Exception("Couldn't initialize selected camera.")

            next_frame = 10 # limit to ~10 fps here

            for res, img in runner.classifier(videoCaptureDeviceId):
                if (next_frame > now()):
                    time.sleep((next_frame - now()) / 1000)

                print('---------------------------------------')
                print('classification runner response', res)
                print(res["result"].keys()) 
                print('---------------------------------------') 

                if "bounding_boxes" in res["result"]:
                    bounding_boxes = res['result']['bounding_boxes']
                    #print('im entered')
                    #print('Result (%d ms.) ' % (res['timing']['dsp'] + res['timing']['classification']), end='')
                    for box in bounding_boxes:
                        label_1 = box['label']
                        score = box['value']
                        if score > 0.85 :
                            print(f'Label : {label_1}, Confidence : {score}')
                            final_weight = abs(find_weight())
                            list_com(label_1,final_weight)
                            if label_1 == c:
                                print('Snickers detected')       
                            elif label_1 == o:
                                print('Orange detected')
                            elif label_1 == s :
                                print('Sauce detected')
                            else:
                                print(f'Label : {label_1}, Confidence level is not high enough i.e less than .8')
                    print('', flush=True)
                next_frame = now() + 100
        finally:
            if (runner):
                runner.stop()

if __name__ == "__main__":
    main(sys.argv[1:])
