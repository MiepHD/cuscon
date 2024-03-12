import os
import re
folders = os.listdir(".")
appfilter = ""
dic = {}
for folder in folders:
    if folder == "stats.py" or folder == "output.txt":
        continue
    with open(folder + "/appfilter.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if ("item" in line):
                line = re.sub(r"[\\\t]+", "", line)
                package = re.sub(r'drawable=".*?\n', "", line)
                if package in dic:
                    dic.update({package:dic.get(package) + 1})
                else:
                    dic.update({package:1})
with open("output.txt", "w", encoding="utf-8") as f:
    sortedlist = sorted(dic.items(), key=lambda x:x[1])
    string = str(sortedlist)
    f.write(string)
