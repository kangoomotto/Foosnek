import os

# Define the directories or file types you want to exclude
EXCLUDE_DIRS = ['.godot', '.import', '__pycache__', 'bin', 'obj', '.git']
EXCLUDE_FILES = ['.gitignore', '.gitattributes']

def print_tree(start_path, indent=0):
    """
    Recursively prints the file system tree structure of the given directory,
    excluding specified directories and files.
    :param start_path: The root directory to start from.
    :param indent: The current indentation level.
    """
    # Check if the directory exists
    if not os.path.exists(start_path):
        print(f"Error: {start_path} does not exist.")
        return

    # Walk through the directory tree
    for root, dirs, files in os.walk(start_path):
        # Filter out excluded directories and files
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        files = [f for f in files if f not in EXCLUDE_FILES]

        # Print the directory name
        level = root.replace(start_path, '').count(os.sep)
        indent_str = ' ' * 4 * level
        print(f"{indent_str}[DIR] {os.path.basename(root)}")

        # Print each file in the directory
        subindent = ' ' * 4 * (level + 1)
        for file in files:
            print(f"{subindent}[FILE] {file}")

# Specify the directory to scan
root_dir = "D:/Godot/SoccerGame"  # Change this to the path of your project folder

# Print the file system tree starting from the root directory
print_tree(root_dir)
