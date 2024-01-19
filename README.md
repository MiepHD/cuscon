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

https://www.patreon.com/Cuscon

# Requests

Please send requests to <a href="mailto:cuscon-requests@froxot.de">cuscon-requests@froxot.de</a>

# Pull Requests

If you want to contribute icons, you can use the icons under `requests` or send a icon request to yourself to get the things you need. Then edit the icons so they match the criteria (Requirements for contributing icons). These go to `app\src\main\res\drawable-nodpi`. After that, extract the parts for your icons from the xml files and paste these in the corresponding files in `app\src\main\res\xml`. To do this easier especially when you only want a part of a request you can use the extractor.py. Install python if you don't have it then run `python ..\extractor.py ` as arguments use the filenames of the icons without fileextension. This will first output the names, then appfilter, appmap and theme_resources. Finally, create a pull request with these changes.<br>

<b>If you just want to create the image, please upload it with the corresponding data in the xml files as an issue.</b>

# Requirements for contributing icons

- Icons must be outlined in black
- Icon must be visible on black background
- dimension of 512x512px
- should have approximate 30px transparent border
- should have approximate 12px brush size

# License

```
Licensed under the Apache License, Version 2.0 (the "License");
http://www.apache.org/licenses/LICENSE-2.0
```
