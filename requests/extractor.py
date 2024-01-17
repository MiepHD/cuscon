import sys
import re

changelog = ""
appfilter = ""
appmap = ""
theme_resources = ""

for elem in sys.argv:
    elem = "\"" + elem + "\""
    with open("appfilter.xml") as f:
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
                appfilter = appfilter + line
            title = line
    with open("appmap.xml") as f:
        for line in f.readlines():
            if (elem in line):
                appmap = appmap + line
    with open("theme_resources.xml") as f:
        for line in f.readlines():
            if (elem in line):
                    theme_resources = theme_resources + line
print(changelog)
print(appfilter)
print(appmap)
print(theme_resources)
