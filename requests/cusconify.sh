#!/bin/sh

# 1st parameter: filename
# 2nd parameter (optional): x coordinate to get background color from
# 3rd parameter (optional): y coordinate to get background color from
# 4th parameter (optional): fuzz percentage for background
# 5th parameter (optional): fuzz percentage for trimming
# 6th parameter (optional): floodfill or replace 

filename="$1"
new_file="new_$filename"
temp_dir="cusconify_temp"

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

mkdir -p $temp_dir

echo "Resize $filename to 512x512"
magick $filename -fuzz 20% -trim -resize 512x512! $temp_dir/$new_file

echo
print_background $filename

echo
echo "Remove background"
if [ "$6" = "replace" ]; then
    magick $temp_dir/$new_file -fill none -fuzz ${4:-25}% -draw "color ${2:-256},${3:-0} replace" "$temp_dir/no_bg_$new_file"
else
    magick $temp_dir/$new_file -fill none -fuzz ${4:-25}% -draw "color ${2:-0},${3:-0} floodfill" "$temp_dir/no_bg_$new_file"
fi

echo "Trim transparent border"
magick "$temp_dir/no_bg_$new_file" -fuzz ${5:-75}% -trim "$temp_dir/trimmed_$new_file"

# resize preserves the aspect ratio, so the longest edge is now 450px
# https://imagemagick.org/Usage/resize/
echo "Resize trimmed image so longest side is 450px"
magick "$temp_dir/trimmed_$new_file" -resize 450x450 "$temp_dir/450_$new_file"

echo "Put 450px trimmed image in center of 512x512 transparent image"
magick "$temp_dir/450_$new_file" -background transparent -gravity center -extent 512x512 "$temp_dir/aio_$new_file"


echo "Generate icon with black borders"
magick "$temp_dir/aio_$new_file" -bordercolor none -border 12 -background black -alpha background -channel A -blur 12x12 -level 0,5% -resize 512x512 "$temp_dir/bordered_$new_file"

echo "Make sure final icon is 512x512"
magick "$temp_dir/bordered_$new_file" -background transparent -gravity center -extent 512x512 "$new_file"
