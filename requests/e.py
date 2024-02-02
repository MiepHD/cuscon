import sys
import re
from os.path import exists

appfilter = ""
conflict = ""
with open("../../app/src/main/res/xml/appfilter.xml", encoding="utf-8") as f1:
    already = f1.read()
    with open("appfilter.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if ("item" in line):
                line = re.sub(r"[\\\t]+", "", line)
                find = re.sub(r'drawable=".*?\n', "", line)
                name = re.search('(?<=e=").*?(?=")', line).group()
                if (exists(name + ".png")):
                    if (find in already):
                        appfilter = appfilter + name + '\n'
                    if (exists("../../app/src/main/res/drawable-nodpi/" + name + ".png")):
                        conflict = conflict + name + '\n'
print(appfilter)
print("Conflicts:")
print(conflict)
