import sys
import re
appfilter = ""
with open("../../app/src/main/res/xml/appfilter.xml", encoding="utf-8") as f1:
    already = f1.read()
    with open("appfilter.xml", encoding="utf-8") as f:
        for line in f.readlines():
            if ("item" in line):
                line = re.sub(r"[\\\t]+", "", line)
                line = re.sub(r"drawable=.*?>", "", line)
                if (line in already):
                    appfilter = appfilter + line
print(appfilter)
