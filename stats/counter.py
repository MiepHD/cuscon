import sys
import re
import os
from os.path import exists

folders = os.listdir(".")
for folder in folders:
    if "." in folder: continue
    os.chdir(folder)
    appfilter = 0
    conflict = 0
    rename = 0
    total = 0
    update = ""
    with open("../../app/src/main/res/xml/appfilter.xml", encoding="utf-8") as f1:
        already = f1.read()
        with open("appfilter.xml", encoding="utf-8") as f:
            for line in f.readlines():
                if ("<item" in line):
                    line = re.sub(r"[\\\t]+", "", line)
                    find = re.sub(r'drawable=".*?\n', "", line)
                    if (re.search('(?<=e=").*?(?=")', line)):
                        name = re.search('(?<=e=").*?(?=")', line).group()
                        if (exists(name + ".png")):
                            total = total + 1
                            if (find in already):
                                appfilter = appfilter + 1
                            elif (find.split("/")[0] in already):
                                update = update + name + ";" + find
                            elif (exists("../../app/src/main/res/drawable-nodpi/" + name + ".webp")):
                                conflict = conflict + 1
                            elif not (re.match(r"[A-Za-z0-9]", name)):
                                rename = rename + 1
    os.chdir("..")
    print(folder + ": " + str(total - appfilter - conflict - rename) + " " + str(conflict) + " " + str(rename))
    print(folder + ": " + update)
