import os
import shutil
import argparse
import re

def format_filename(dirname, filename, existing_filenames, parent_dirs):
    filename = filename.lower().replace(' ', '_')
    dirname = dirname.lower().replace(' ', '_')

    if filename == "readme.md":
        new_filename = f"{dirname}.md"
    elif filename.startswith(dirname):
        new_filename = filename
    else:
        new_filename = f"{dirname}_{filename}"

    if not new_filename.endswith(".md"):
        new_filename += ".md"

    # Ensure unique filename
    parent_level = 0
    while new_filename in existing_filenames:
        if parent_level < len(parent_dirs):
            parent_dir = parent_dirs[-(parent_level + 1)]
            new_filename = f"{parent_dir}_{new_filename}"
            parent_level += 1
        else:
            new_filename = f"{parent_level}_{new_filename}"
            parent_level += 1

    existing_filenames.add(new_filename)
    return new_filename

def process_files(source, dest):
    image_extensions = ['.png', '.jpeg', '.jpg', '.gif', '.bmp']
    existing_filenames = set()
    existing_images = set()

    for root, _, files in os.walk(source):
        parent_dirs = os.path.relpath(root, source).split(os.sep)
        dirname = os.path.relpath(root, source).replace('.', '').replace('/', '_')
        for file in files:
            if file.endswith('.md'):
                src_file_path = os.path.join(root, file)
                new_filename = format_filename(dirname, file, existing_filenames, parent_dirs)
                dest_dir_path = os.path.join(dest, dirname)
                dest_file_path = os.path.join(dest, new_filename)
                # os.makedirs(dest_dir_path, exist_ok=True)

                with open(src_file_path, 'r') as f:
                    content = f.read()

                # Find and replace image links
                content = re.sub(r'!\[.*?\]\((.*?)\)', lambda match: replace_image_link(match, root, dest_dir_path, existing_images, image_extensions), content)

                with open(dest_file_path, 'w') as f:
                    f.write(content)

                print(f"Copied and modified {src_file_path} to {dest_file_path}")

def replace_image_link(match, root, dest_dir_path, existing_images, image_extensions):
    image_path = match.group(1)
    image_name = os.path.basename(image_path)
    image_ext = os.path.splitext(image_name)[1].lower()

    if image_ext not in image_extensions:
        return match.group(0)

    # Ensure unique image filename
    new_image_name = image_name.lower().replace(' ', '_')
    parent_level = 0
    parent_dirs = os.path.relpath(root, source).split(os.sep)
    while new_image_name in existing_images:
        if parent_level < len(parent_dirs):
            parent_dir = parent_dirs[-(parent_level + 1)]
            new_image_name = f"{parent_dir}_{new_image_name}"
            parent_level += 1
        else:
            new_image_name = f"{parent_level}_{new_image_name}"
            parent_level += 1

    existing_images.add(new_image_name)
    new_image_path = os.path.join(dest_dir_path, "img", new_image_name)
    os.makedirs(os.path.join(dest_dir_path, "img"), exist_ok=True)
    
    src_image_path = os.path.join(root, image_path)
    if os.path.exists(src_image_path):
        shutil.copy2(src_image_path, new_image_path)
        print(f"Copied image {src_image_path} to {new_image_path}")
    else:
        print(f"Image {src_image_path} not found!")

    return f"![](img/{new_image_name})"

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Copy and rename .md files and handle images")
    parser.add_argument('-s', '--source', required=True, help="Source directory")
    parser.add_argument('-d', '--dest', required=True, help="Destination directory")
    
    args = parser.parse_args()
    
    confirmation = input(f"The script will process .md files and images from {args.source} to {args.dest}, and the destination directory will be removed if it exists.\nIs this correct? (yes/no): ")
    if confirmation.lower() == 'yes':
        source = args.source
        # Remove destination directory if it exists
        if os.path.exists(args.dest):
            shutil.rmtree(args.dest)        
        os.makedirs(args.dest, exist_ok=True)
        process_files(source, args.dest)
    else:
        print("Operation cancelled.")
