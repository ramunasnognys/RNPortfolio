#!/bin/bash

# Check if a directory was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

source_dir="$1"
target_dir="${source_dir}_flattened"

# Create target directory if it doesn't exist
mkdir -p "$target_dir"

# Function to sanitize path for filename
sanitize_path() {
    # Replace directory separators with DIRSPEC
    echo "$1" | sed 's/\//@DIRSPEC@/g' | sed 's/\\/@DIRSPEC@/g'
}

# Find all files recursively and process them
find "$source_dir" -type f | while read -r file; do
    # Get relative path from source directory
    rel_path="${file#$source_dir/}"
    
    # Get directory path and filename
    dir_path=$(dirname "$rel_path")
    filename=$(basename "$file")
    
    # Skip if file is in root directory
    if [ "$dir_path" = "." ]; then
        continue
    }
    
    # Create new filename with encoded path
    # Format: {original_path}@DIRSPEC@{filename}
    sanitized_path=$(sanitize_path "$dir_path")
    new_filename="${sanitized_path}@DIRSPEC@${filename}"
    
    # Copy file to target directory with new name
    cp "$file" "$target_dir/$new_filename"
    
    echo "Processed: $rel_path -> $new_filename"
done

echo "
Repository flattening complete!
Output directory: $target_dir

Files have been copied with their paths encoded in their names.
- Original paths are encoded using @DIRSPEC@ as separator
- Example: src@DIRSPEC@utils@DIRSPEC@helper.js was originally src/utils/helper.js

To restore original paths later, use:
echo 'filename' | sed 's/@DIRSPEC@/\//g'
"