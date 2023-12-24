# Imagemagick

### example how to use

```v
import freeflowuniverse.crystallib.tools.imagemagick

imagemagick.downsize(
    path:"/tmp/mydir"
    backupdir:"/tmp/mybackup"
    redo:true //will re-process
    convertpng:true //will convert from png to jpeg
)!

imagemagick.downsize(
    path:"/tmp/mydir/myimage.png"
    backupdir:"/tmp/mybackup"
    redo:true //will re-process
    convertpng:false //will not convert to jpeg
)!


```

### example output of image once identified

```json
Image{
    path: path: /tmp/code/github/threefoldfoundation/www_examplesite/src/assets/images/sliders/availability.png
    size_x: 1448
    size_y: 573
    resolution_x: 28
    resolution_y: 28
    size_kbyte: 414
    transparent: true
}
```