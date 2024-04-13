import sys
import re
import os
from os.path import exists

appfilter = ""
conflict = ""
with open("../../app/src/main/res/xml/appfilter.xml", encoding="utf-8") as f1:
    already = f1.read()
    with open("appfilter.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if ("<item" in line):
                line = re.sub(r"[\\\t]+", "", line)
                find = re.sub(r'drawable=".*?\n', "", line)
                name = re.search('(?<=e=").*?(?=")', line).group()
                if (exists(name + ".png")):
                    if (find in already):
                        appfilter = appfilter + name + '\n'
                    if (exists("../../app/src/main/res/drawable-nodpi/" + name + ".webp")):
                        conflict = conflict + name + '\n'

if (len(sys.argv) > 1):
    if (sys.argv[1]=="-rmaa"):
        for file in appfilter.split("\n"):
            if (file != ""):
                print("Deleting " + file)
                os.remove(file + ".png")
    elif (sys.argv[1]=="-rmcon"):
        for file in conflict.split("\n"):
            if (file != "" and exists("get/" + file + ".png")):
                print("Deleting " + file)
                os.remove("get/" + file + ".png")
else:
    print(appfilter)
    print("Conflicts:")
    print(conflict)