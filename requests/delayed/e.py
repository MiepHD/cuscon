import sys
import re
from os.path import exists

appfilter = ""
with open("../../app/src/main/res/xml/appfilter.xml", encoding="utf-8") as f1:
    already = f1.read()
    with open("appfilter.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if ("item" in line):
                line = re.sub(r"[\\\t]+", "", line)
                find = re.sub(r'drawable=".*?\n', "", line)
                if (find in already):
                    name = re.search('(?<=e=").*?(?=")', line).group()
                    if (exists(name + ".png")):
                        appfilter = appfilter + name + '\n'
print(appfilter)
