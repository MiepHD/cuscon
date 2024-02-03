#!/bin/sh

# 1st parameter: filename
# 2nd optional parameter: fuzz percentage

filename="$1"
new_file="new_$filename"

print_background() {
    echo "Colors around the edge of $1 to get the background color"
    for x in 0 256 512
    do
        for y in 0 256 512
        do
            if [ $x != 256 ] || [ $y != 256 ]; then
                magick $1 -format "Color at ($x,$y) %[pixel:u.p{$x,$y}]\n" info:
            fi
        done
    done
}

echo "Resize $filename to 512x512"
magick $filename -resize 512x512! $new_file

echo
print_background $filename

echo
# resize preserves the aspect ratio, so the longest edge is now 450px
# https://imagemagick.org/Usage/resize/
echo "Remove the background, trim the transparent border, and resize the image so the longest side is 450px, and add transparent border such that the image is 512x512 with the icon in the center"
magick $new_file -fill none -fuzz ${2:-50}% -draw 'color 0,0 floodfill' -trim -resize 450x450 -background transparent -gravity center -extent 512x512 $new_file

echo "Generate icon with black borders"
magick $new_file -bordercolor none -border 12 -background black -alpha background -channel A -blur 12x12 -level 0,5% "bordered_$new_file"
