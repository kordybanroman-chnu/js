import os
import json

def generate_file_tree(root_dir):
    tree = {}
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if '.git' in dirnames:
            dirnames.remove('.git')
        rel_path = os.path.relpath(dirpath, root_dir)
        if rel_path == '.':
            current = tree
        else:
            parts = rel_path.split(os.sep)
            current = tree
            for part in parts:
                if part not in current:
                    current[part] = {}
                current = current[part]
        for dirname in dirnames:
            if dirname not in current:
                current[dirname] = {}
        for filename in filenames:
            current[filename] = None

        # Sort: directories first, then files
        sorted_items = {}
        dirs = {k: v for k, v in current.items() if isinstance(v, dict)}
        files = {k: v for k, v in current.items() if v is None}
        for k in sorted(dirs.keys()):
            sorted_items[k] = dirs[k]
        for k in sorted(files.keys()):
            sorted_items[k] = files[k]
        current.clear()
        current.update(sorted_items)

    return tree

if __name__ == "__main__":
    parent_dir = os.path.dirname(os.path.abspath(__file__))
    file_tree = generate_file_tree(parent_dir)
    with open('html_tree.json', 'w') as f:
        json.dump(file_tree, f, indent=4)