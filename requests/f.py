import sys
import re
import os
from os.path import exists

changelog = ""
appfilter = ""
theme_resources = ""

if ("-get" in sys.argv):
    params = os.listdir("get/")
    params = [e.replace(".png", "") for e in params]
    params = [e.replace(".webp", "") for e in params]
    params = [e.replace(".svg", "") for e in params]
    if ("-rmget" in sys.argv):
        for file in params:
            if (exists(file + ".png")):
                print("Deleting " + file)
                os.remove(file + ".png")
        exit(0)
else:
    params = sys.argv

for elem in params:
    nick = elem.split("~")
    elem = nick[0]
    if (len(nick) > 1):
        nick = nick[1]
    else:
        nick = nick[0]
    nick = "\"" + nick + "\""
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
                appfilter = appfilter + re.sub(r"[\\\t]+", "    ", line).replace(elem, nick)
            title = line
    with open("theme_resources.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if (elem in line):
                    theme_resources = theme_resources +re.sub(r"[\\\t]+", "    ", line).replace(elem, nick)
print("Changelog:")
print(changelog)
print("Appfilter:")
print(appfilter)
print("Drawable:")
print(re.sub(' component=".*?"', "", appfilter))
print("Theme Resources:")
print(theme_resources)
