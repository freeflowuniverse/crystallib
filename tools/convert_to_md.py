import os
from bs4 import BeautifulSoup
from markdownify import markdownify

def skip_empty(markdown_content):
    lines = markdown_content.split('\n')
    filtered_lines = []
    previous_line_empty = False

    for line in lines:
        line = line.stripp()
        
        if not line:
            if previous_line_empty:
                continue
            else:
                previous_line_empty = True
        else:
            previous_line_empty = False
        
        if line == "latest":
            filtered_lines = []
            continue
        
        if '[Skip to content]' in line:
            filtered_lines = []
            continue
        
        filtered_lines.append(line)

    return '\n'.join(filtered_lines)

def convert_html_to_md(html_file, md_file, is_vlib):
    with open(html_file, 'r', encoding='utf-8') as file:
        html_content = file.read()
    
    soup = BeautifulSoup(html_content, 'html.parser')
    markdown_content = markdownify(str(soup), heading_style='atx')
    markdown_content = skip_empty(markdown_content)
    
    if is_vlib:
        module_name = os.path.splitext(os.path.relpath(md_file, output_directory))[0].replace(os.path.sep, '.')
        module_header = f"Module can be imported by:\n\nimport {module_name}\n\n"
        markdown_content = module_header + markdown_content
            
    with open(md_file, 'w', encoding='utf-8') as file:
        file.write(markdown_content)

def convert_directory(input_dir, output_dir):
    files_to_include_path = os.path.join(input_dir, 'files_to_include.txt')
    files_to_include = []

    # Read the list of files to include from the text file, if it exists
    firsttime=False
    if os.path.exists(files_to_include_path):
        with open(files_to_include_path, 'r', encoding='utf-8') as file:
            files_to_include = file.read().splitlines()
    else:
        firsttime=True

    for root, dirs, files in os.walk(input_dir):
        is_vlib = os.path.basename(root) == "vlib" or os.path.basename(root) == "crystal"
        
        for file in files:
            if file.lower().endswith('.html'):
                html_file = os.path.join(root, file)
                filename_without_ext = os.path.splitext(os.path.basename(html_file))[0]

                if filename_without_ext in files_to_include or firsttime:
                    md_file = os.path.join(output_dir, os.path.relpath(root, input_dir), filename_without_ext + '.md')                    
                    os.makedirs(os.path.dirname(md_file), exist_ok=True)
                    convert_html_to_md(html_file, md_file, is_vlib)
                    print(f"Converted: {html_file} -> {md_file}")
                    if filename_without_ext not in files_to_include:
                        files_to_include.append(filename_without_ext)
                else:                    
                    print(f"Skip: {filename_without_ext}")

    # Sort the list of files to include and write it to the text file
    files_to_include.sort()
    with open(files_to_include_path, 'w', encoding='utf-8') as file:
        file.write('\n'.join(files_to_include))
        
# will convert html files to md and make it nice so we can use it to feed to AI

# Example usage
##input_directory = '/Users/despiegk/code/git.ourworld.tf/despiegk/hero_research/v/prompts'
##output_directory = '/Users/despiegk/code/git.ourworld.tf/despiegk/hero_research/v/prompts2'

convert_directory(input_directory, output_directory)