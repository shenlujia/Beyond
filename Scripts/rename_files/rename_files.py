import os
import time

path = os.getcwd()
files = os.listdir(path)
files.sort()
print("====== all files:")
print(files)
print("======")

prefix = time.strftime("%m-%d-%H_%M_%S", time.localtime())

index = 1
for filename in files:
    parts = filename.partition(".")
    if len(parts[0]) == 0 or len(parts[1]) == 0 or len(parts[2]) == 0:
        continue
    suffix = parts[2]
    if suffix == "py" or suffix == "DS_Store":
        continue
    to = prefix + "-" + str(index) + "." + suffix
    message = "old: " + filename + "      new: " + to
    print(message)
    index += 1
    #os.rename(filename, to)
