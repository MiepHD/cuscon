If you want to contribute see [Contributing](https://github.com/MiepHD/cuscon/edit/master/README.md#contributing)

![icon_with_name](http://miep-hd.froxot.com/cuscon/res/icon_with_name.png)

This icon pack brings variety and dynamism to your Home screen with over 5000 icons. Without a background, each icon looks unique and breaks the constant pattern of the grid. All icons have a black border which allows them to fit on most backgrounds. The color palette is retained and integrated into the icon. This makes the icons easy to recognize. Cuscon also brings a natural consistency to the size of the icons. All icons have the same spacing, resulting in a standard size without the need to mask icons. Unlike many other icon packs, Cuscon's philosophy supports the creation of icons for games and other complex icons. Therefore, it is possible to have Cuscon fully applied without annoying unedited icons that don't fit the theme. Since Cuscon is open source, anyone can contribute icons and other changes on Github. Cuscon supports most launchers such as Apex, Nova, Smart, Kiss, Lawnchair and others. You can request icons that have not yet been added to the application. Most calendars can update based on the date if the correct launcher is used.

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

# Images

<img src="https://github.com/MiepHD/cuscon/assets/63968466/183ac3f3-c5a1-4d08-becb-658f0b69a74e" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/a2be67df-4dbd-40db-8e9d-cd597146a75d" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/9c2580ec-8704-4fe6-9dfd-024f668cba51" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/8ba07e70-6279-447e-a349-149fe25c831a" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/f433a4e0-fb98-44d0-b1c9-3a7a80deccf5" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/45310e7d-f102-450d-9c3f-391050e14dcc" width="400" />
<img src="https://github.com/MiepHD/cuscon/assets/63968466/17325662-5498-47d8-8e2c-a3e798455db0" width="400" />

# Requests

Please send requests to <a href="mailto:cuscon-requests@froxot.de">cuscon-requests@froxot.de</a>

# Contributing

## Issues

<b>If you just want to create the images, please upload the request with edited images as an issue.</b>

## Pull Requests

Requirements:
- Python
- Bash

How-To:

1. If you want to contribute icons, you can use<br>
   &nbsp;&nbsp;&nbsp;a) the icons under `requests`<br>
   &nbsp;&nbsp;&nbsp;b) send a icon request to yourself (use v4.0.1.7)<br>
   to get the details you need
2. Extract the content of your request into `requests/icon_request`
3. Run `python ../e.py` in the extracted request folder to get these details:
   1. List of icons that are in the request but already in the latest version. To remove them run `python ..\e.py -rmaa`
   2. List with filename conflicts.<br>
      a) The icon in the request is the original version of the icon with the same filename in the app:<br>
         &nbsp;&nbsp;&nbsp;Get the details of the icon with `python ../f.py <filename>` and add the data under `theme_resources` and `appfilter` to `app/src/main/res/xml/theme_resources.xml` and `app/src/main/res/xml/appfilter.xml`<br>
      b) The icon in the request doesn't match the one in the app and<br>
           &nbsp;&nbsp;&nbsp;A) the icon is already added but under another name:<br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get the details of the icon with `python ../f.py <filename>~<filename in app>` and add the data under `theme_resources` and `appfilter` to `app/src/main/res/xml/theme_resources.xml` and `app/src/main/res/xml/appfilter.xml`<br>
           &nbsp;&nbsp;&nbsp;B) the icon isn't added under another name:<br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Replace the file with your edited version. Get the details of the icon with `python ../f.py <filename>`. Then read the details under Appfilter like `region.author.abc/`. From this info think of a filename like `author_abc` and an incremental number if neccessary. Rename the icon to the unique name. Then proceed at 4. but run `python ../f.py <filename>~<newname>` instead of step 9. .<br>
      c) If you don't want to handle these:<br>
           &nbsp;&nbsp;&nbsp;Use `python ../e.py -rmcon` to delete all conflicts
4. Edit the icons so they match the criteria (Requirements for contributing icons)
5. Put them into a subfolder called `get`
6. Check if the latest version in `app/src/main/res/values/changelog.xml` is already released
   True) 1. Add new items for the new version in the changelog
         2. Update the `versionCode` and `versionName` in `app/build.gradle`
         3. Create `metadata/en-US/changelogs/<versionCode>.txt`
7. Change the date in `app/src/main/res/values/changelog.xml` to the current date
8. Run in the folder of the request `python ../f.py -get`
9. Copy the changelog into `app\src\main\res\values\changelog.xml` and `metadata/en-US/changelogs/<versionCode>.txt`
10. Copy the appfilter details into `app/src/main/res/xml/appfilter.xml`, the drawable into `app/src/main/res/xml/drawable.xml` and the theme_resources into `app/src/main/res/xml/theme_resources.xml`
11. (Optional) Convert the png files in the get folder to webp files ([WebP Converter for Windows and MacOS](https://anywebp.com/de/software))
12. Move the images to `app/src/main/res/drawable-nodpi`
13. (Optional) Do a gradle sync
14. Finally, create a pull request with these changes.

# Requirements for contributing icons

- Icons must be outlined in black
- Icon should be visible on black background
- dimension of 512x512px
- should have approximate 30px transparent border
- should have approximate 12px brush size

# License

The app is built with the **[CandyBar Dashboard](https://github.com/zixpo/candybar)** (and also with the **[FOSS version](https://github.com/Donnnno/candybar-foss)**) licensed under **[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)**

The icons are licensed under **[Creative Commons BY-NC-ND License 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)**

All files under `/store` and `/metadata` except `metadata/en-US/changelogs` are © Copyrighted by [@MiepHD](https://github.com/MiepHD) 2024
