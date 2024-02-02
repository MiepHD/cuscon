![icon_with_name](http://miep-hd.froxot.com/cuscon/res/icon_with_name.png)

This icon pack makes your home screen varied and dynamic. As there is no background, each icon looks unique and the constant pattern of the grid is broken up.

# Download

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/com.froxot.cuscon.foss/)
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=com.froxot.cuscon)

Or download the latest APK from the [Releases Section](https://github.com/MiepHD/cuscon/releases/latest).

# Donate

https://www.buymeacoffee.com/yazazuyo

# Requests

Please send requests to <a href="mailto:cuscon-requests@froxot.de">cuscon-requests@froxot.de</a>

# Pull Requests

If you want to contribute icons, you can use the icons under `requests` or send a icon request to yourself to get the things you need. Install python if you don't have it then run `python e.py` in the request to get first a list of the icons that are in the request and already added and second a list with filename conflicts. If there are any conflicts go see if the file is already the right one, then only the xml files have to be updated otherwise chosse another name and rename the file as well as the filename in the xml files of your request. Then edit the icons so they match the criteria (Requirements for contributing icons). These go to `app\src\main\res\drawable-nodpi`. After that, extract the parts for your icons from the xml files using `f.py` and paste these in the corresponding files in `app\src\main\res\xml`. Run `python ..\f.py ` as arguments use the filenames of the icons without fileextension. This will first output the names, then appfilter, appmap and theme_resources. The names at the beginning of the output go to `app\src\main\res\values\changelog.xml` and `metadata\en-US\changelogs\<versionCode>.txt`. Finally, create a pull request with these changes.<br>

<b>If you just want to create the image, please upload it with the corresponding data in the xml files as an issue.</b>

# Requirements for contributing icons

- Icons must be outlined in black
- Icon should be visible on black background
- dimension of 512x512px
- should have approximate 30px transparent border
- should have approximate 12px brush size

# License

```
Licensed under the Apache License, Version 2.0 (the "License");
http://www.apache.org/licenses/LICENSE-2.0
```
