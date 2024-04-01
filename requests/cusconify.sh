#!/bin/sh

prep() {
    filename="$1"

    mkdir -p get

    echo "Editing $filename"
    magick $filename -fuzz 20% -trim -resize 512x512 +repage "get/$filename"
        cusconify $filename
}

cusconify() {
    r=$(magick get/$filename -format "%[fx:round(255*u.p{10,256}.r)]" info:)
    g=$(magick get/$filename -format "%[fx:round(255*u.p{10,256}.g)]" info:)
    b=$(magick get/$filename -format "%[fx:round(255*u.p{10,256}.b)]" info:)
    a=$(magick get/$filename -format "%[fx:round(255*u.p{10,256}.a)]" info:)
    luma=$(awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN { printf "%.0f", (r + g + b) / 3 }')
    echo "Luma: $luma"
    echo "Transparency: $a"
    if [ "$a" != "0" ]; then
        echo "Remove background"
        magick "get/$filename" -fill none -fuzz 35% -draw "color 10,256 replace" +repage "get/$filename"
    fi

    magick "get/$filename" -fuzz 75% -trim +repage "get/$filename"
    
    if [ "$a" = "0" ]; then
        magick $filename -fuzz 20% -trim -resize 512x512 +repage "get/$filename"

        echo "Get three more pixels to better evaluate"
        left=$(magick get/$filename -format "%[fx:round(255*u.p{10,256}.a)]" info:)
        right=$(magick get/$filename -format "%[fx:round(255*u.p{502,256}.a)]" info:)
        top=$(magick get/$filename -format "%[fx:round(255*u.p{256,10}.a)]" info:)
        bottom=$(magick get/$filename -format "%[fx:round(255*u.p{256,502}.a)]" info:)

        if [ "$left" != "0" ] && [ "$right" != "0" ] && [ "$top" != "0" ] && [ "$bottom" != "0" ]; then
            echo "Do cusconify again with cropped and resized image"
            cusconify $filename
        fi
    fi

    magick "get/$filename" -resize 450x450 +repage "get/$filename"

    magick "get/$filename" -background transparent -gravity center -extent 512x512 +repage "get/$filename"
    magick "get/$filename" -background transparent -gravity center -extent 512x512 +repage "get/$filename"

    black=$(convert $filename -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#000000ff')

    if [ "$a" != "0" ] && [ luma > 70 ] ; then
        if [ -z "$black" ]; then
            echo "Replace white with background color"
            magick get/$filename -fuzz 15% -fill "srgba($r,$g,$b,$a)" -opaque white get/$filename
        else
            echo "Replace black with background color"
            magick get/$filename -fuzz 15% -fill "srgba($r,$g,$b,$a)" -opaque black get/$filename
        fi
    else
        echo "Background color too dark or no background"
    fi

    magick "get/$filename" -bordercolor none -border 12 -background black -alpha background -channel A -blur 12x12 -level 0,5% -resize 512x512 +repage "get/$filename"
}

for file in *.png
do 
    prep $file
done
