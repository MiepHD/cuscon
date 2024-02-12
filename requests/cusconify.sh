#!/bin/sh

print_background() {
    echo "Colors around the edge of $1"
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

cusconify() {
    # 1st parameter: filename
    # 2nd parameter (optional): x coordinate to get background color from
    # 3rd parameter (optional): y coordinate to get background color from
    # 4th parameter (optional): fuzz percentage for background
    # 5th parameter (optional): fuzz percentage for trimming
    # 6th parameter (optional): floodfill or replace 

    filename="$1"
    new_file="new_$filename"
    temp_dir="cusconify_temp"


    mkdir -p $temp_dir
    mkdir -p get

    echo "Resize $filename to 512x512"
    magick $filename -fuzz 20% -trim -resize 512x512 +repage $temp_dir/$new_file

    echo
    print_background $filename
    print_background $temp_dir/$new_file

    echo
    echo "Remove background"
    if [ "$6" = "floodfill" ]; then
        magick $temp_dir/$new_file -fill none -fuzz ${4:-40}% -draw "color ${2:-256},${3:-0} floodfill" +repage "$temp_dir/no_bg_$new_file"
    else
        magick $temp_dir/$new_file -fill none -fuzz ${4:-40}% -draw "color ${2:-256},${3:-0} replace" +repage "$temp_dir/no_bg_$new_file"
    fi

    echo "Trim transparent border"
    magick "$temp_dir/no_bg_$new_file" -fuzz ${5:-75}% -trim +repage "$temp_dir/trimmed_$new_file"

    # resize preserves the aspect ratio, so the longest edge is now 450px
    # https://imagemagick.org/Usage/resize/
    echo "Resize trimmed image so longest side is 450px"
    magick "$temp_dir/trimmed_$new_file" -resize 450x450 +repage "$temp_dir/450_$new_file"

    echo "Put 450px trimmed image in center of 512x512 transparent image"
    magick "$temp_dir/450_$new_file" -background transparent -gravity center -extent 512x512 +repage "$temp_dir/aio_$new_file"


    echo "Generate icon with black borders"
    magick "$temp_dir/aio_$new_file" -bordercolor none -border 12 -background black -alpha background -channel A -blur 12x12 -level 0,5% -resize 512x512 +repage "$temp_dir/bordered_$new_file"

    echo "Make sure final icon is 512x512"
    magick "$temp_dir/bordered_$new_file" -background transparent -gravity center -extent 512x512 +repage "$temp_dir/bordered_$new_file"

    echo
    echo "To replace white with the background color run:"
    eval "magick $temp_dir/bordered_$new_file -fuzz 15% -fill '$(magick $temp_dir/$new_file -format "%[pixel:u.p{$x,$y}]\n" info:)' -opaque white get/$filename"
    echo "If the background color should be different, just change the srgba value passed in."
    echo "If the result replaces too much or not enough with the background color, try adjusting the fuzz percentage."
}




for file in *.png
do 
    cusconify $file
done