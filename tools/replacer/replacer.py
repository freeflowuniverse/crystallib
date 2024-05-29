import os
import sys
import re

def process_file(file_path):
    exit(1) #do not use as is, because this one has been executed already
    with open(file_path, 'r') as file:
        lines = file.readlines()
    
    import_statement = "import freeflowuniverse.crystallib.ui.console"
    modified_lines = []
    import_found = False
    modified = False

    for line in lines:
        if import_statement in line:
            import_found = True
            
        if 'console.' in line:
            modified = True              
        
        new_line = re.sub(r'\bprint\s*\(\s*', 'console.print_debug(', line)
        new_line = re.sub(r'\bprintln\s*\(\s*', 'console.print_debug(', new_line)
        if new_line != line:
            modified = True
        
        modified_lines.append(new_line)
    
    if not import_found:
        insert_index = 0
        for i, line in enumerate(modified_lines):
            if line.strip().startswith('import ') or line.strip().startswith('module '):
                insert_index = i + 1
        modified_lines.insert(insert_index, f"{import_statement}\n")
    
    if modified:
        with open(file_path, 'w') as file:
            file.writelines(modified_lines)
        print(f"Processed and modified: {file_path}")

def walk_directory(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.v'):
                file_path = os.path.join(root, file)
                process_file(file_path)

if __name__ == "__main__":
    directory = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    
    confirmation = input(f"The script will process files in the directory: {directory}\nIs this correct? (yes/no): ")
    if confirmation.lower() == 'yes':
        walk_directory(directory)
    else:
        print("Operation cancelled.")
