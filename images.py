import os
import re
import shutil
import hashlib

# Paths (using raw strings to handle Windows backslashes correctly)
posts_dir = r"C:\Users\Ramunas\AnthropicFun\hugo-portfolio\content\posts"
attachments_dir = r"C:\Users\Ramunas\AnthropicFun\Second_Brain\posts\Attachments"
static_images_dir = r"C:\Users\Ramunas\AnthropicFun\hugo-portfolio\static\images"

def calculate_hash(filepath):
    """Calculate the SHA-256 hash of a file."""
    hasher = hashlib.sha256()
    with open(filepath, 'rb') as file:
        while True:
            chunk = file.read(4096)
            if not chunk:
                break
            hasher.update(chunk)
    return hasher.hexdigest()

# Create a dictionary to store the hashes of processed files
file_hashes = {}

# Load existing file hashes from a file (if it exists)
hash_file = "file_hashes.txt"
if os.path.exists(hash_file):
    with open(hash_file, "r") as f:
        for line in f:
            filepath, file_hash = line.strip().split(":", 1)
            file_hashes[filepath] = file_hash

# Step 1: Process each markdown file in the posts directory
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)

        # Calculate the hash of the current file
        current_hash = calculate_hash(filepath)

        # Check if the file has been modified since the last run
        if filepath in file_hashes and file_hashes[filepath] == current_hash:
            print(f"Skipping {filename} as it hasn't been modified.")
            continue

        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Step 2: Find all image links in the format ![[filename.png]]
        images = re.findall(r'!\[\[(.*?\.png)\]\]', content)
        
        # Step 3: Replace image links and ensure URLs are correctly formatted
        for image in images:
            # Convert URL-encoded filename back to normal for filesystem operations
            decoded_image = image.replace('%20', ' ')
            image_source = os.path.join(attachments_dir, decoded_image)
            image_target = os.path.join(static_images_dir, decoded_image)
            
            if os.path.exists(image_source):
                # Check if the image already exists in the static directory and if it's different
                if not os.path.exists(image_target) or calculate_hash(image_source) != calculate_hash(image_target):
                    # Copy the image to the static directory
                    shutil.copy(image_source, static_images_dir)
                    print(f"Copied {decoded_image} to {static_images_dir}")
                else:
                    print(f"Image {decoded_image} already exists and is up to date.")
            else:
                print(f"Warning: Image {decoded_image} not found in {attachments_dir}")
            
            # Prepare the Markdown-compatible link with %20 replacing spaces
            url_encoded_image = image.replace(' ', '%20')
            markdown_image = f"![{image}](/images/{url_encoded_image})"
            content = content.replace(f"![[{image}]]", markdown_image)
            
        # Step 5: Write the updated content back to the markdown file
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(content)

        # Update the hash in the dictionary
        file_hashes[filepath] = current_hash

# Save the updated file hashes to the file
with open(hash_file, "w") as f:
    for filepath, file_hash in file_hashes.items():
        f.write(f"{filepath}:{file_hash}\n")

print("Markdown files processed and images copied successfully.")