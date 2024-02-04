import sys
import re
import os
from os.path import exists

changelog = ""
appfilter = ""
appmap = ""
theme_resources = ""

if (len(sys.argv) == 0):
    params = os.listdir("get/")
    params = [e.replace(".png", "") for e in params]
else:
    params = sys.argv

for elem in params:
    elem = "\"" + elem + "\""
    with open("appfilter.xml", encoding="utf-8") as f:
        title = ""
        for line in f.readlines():
            if (elem in line):
                res = re.search("(?<=\\- ).*?(?= -)", title)
                if res:
                    title = res.group()
                if changelog == "":
                    changelog = title
                else:
                    changelog = changelog + ", " + title
                appfilter = appfilter + re.sub(r"[\\\t]+", "    ", line)
            title = line
    with open("appmap.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if (elem in line):
                appmap = appmap + re.sub(r"[\\\t]+", "    ", line)
    with open("theme_resources.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if (elem in line):
                    theme_resources = theme_resources +re.sub(r"[\\\t]+", "    ", line)
print(changelog)
print(appfilter)
print(appmap)
print(re.sub(' component=".*?"', "", appfilter))
print(theme_resources)
