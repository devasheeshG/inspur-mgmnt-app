#!/bin/zsh

# Script to remove [xxxx] prefix from filenames and delete duplicates
# Usage: ./deduplicate-requests.sh

echo "Starting deduplication process..."

# Counter for renamed files
renamed_count=0
duplicate_count=0

# Loop through all files with [xxxx] prefix
for file in \[*\]*.txt; do
    # Skip if no files match the pattern
    [[ ! -e "$file" ]] && continue
    
    # Extract the new filename by removing the [xxxx] prefix
    newname=$(echo "$file" | sed 's/^\[[0-9]*\] //')
    
    # Check if this filename has already been created
    if [[ -f "$newname" ]]; then
        echo "Duplicate found: $file -> $newname (removing duplicate)"
        rm "$file"
        ((duplicate_count++))
    else
        echo "Renaming: $file -> $newname"
        mv "$file" "$newname"
        ((renamed_count++))
    fi
done

echo ""
echo "Deduplication complete!"
echo "Files renamed: $renamed_count"
echo "Duplicates removed: $duplicate_count"
