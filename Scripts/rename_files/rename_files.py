import os
import time

path = os.getcwd()

files = os.listdir(path)

prefix = time.strftime("%m-%d-%H_%M_%S", time.localtime())

index = 1
for filename in files:
    if "." in filename and ".py" not in filename:
        to = prefix + "-" + str(index) + ".txt"
        index += 1
        os.rename(filename, to)
