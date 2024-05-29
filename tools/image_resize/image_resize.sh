function image_resize {
    # Check if the image directory is provided as an argument
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <image-directory>"
        exit 1
    fi

    # Directory containing the images (from the first argument)
    IMAGE_DIR="$1"

    # Desired maximum width and height
    MAX_WIDTH=1200
    MAX_HEIGHT=1024  # You can change this as needed

    # Backup directory for original images
    BACKUP_DIR="$HOME/backup/images"

    # Create the backup directory
    mkdir -p "$BACKUP_DIR"

    # Function to resize and backup images
    process_image() {
        set -ex
        local img=$1
        local filename=$(basename "$img")
        local rel_dir=$(dirname "${img#./}")
        local backup_subdir="$BACKUP_DIR/$rel_dir"

        # Create backup subdirectory
        echo " -- $backup_subdir"
        mkdir -p "$backup_subdir"

        # Move original image to backup directory
        mv "$img" "$backup_subdir/$filename"

        # Resize and replace the image in the original location
        convert "$backup_subdir/$filename" -resize "${MAX_WIDTH}x${MAX_HEIGHT}>" "$img"
    }

    # Export the function for use in find -exec
    export -f process_image

    # Find and process images
    find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \) -not -path "$IMAGE_DIR/.*" -not -path "$IMAGE_DIR/_*" -exec bash -c 'process_image "$0"' {} \;

    echo "Resizing completed. Original images are backed up in $BACKUP_DIR"
}