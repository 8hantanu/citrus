#!/bin/bash

wiki_folder="$1"

cd $wiki_folder

# Declare an associative array to store links with relative directory as keys
declare -A unique_links

# Find all Markdown files in the wiki folder and its subfolders (excluding hidden folders)
all_markdown_files=$(find "$wiki_folder" -type f -name "*.md" ! -path "*/.*")

# Loop through each markdown file
for markdown_file in $all_markdown_files; do

  # Get the relative path from the current directory to the markdown file
  relative_dir=$(realpath --relative-to="$wiki_folder" "$(dirname "$markdown_file")")

  # Extract unique links from the markdown file, excluding https links
  extracted_links=($(grep -o '\[.*\](.*)' "$markdown_file" | sed "s/.*](\(.*\)).*/\1/" | grep -v 'http' | sort -u))

  # Loop through extracted links and add to unique_links with relative directory as key
  for ((i=0; i<${#extracted_links[@]}; i++)); do
    if [[ "$relative_dir" == "." ]]; then
      link="${extracted_links[$i]}"
    else
      link="$relative_dir/${extracted_links[$i]}"
    fi
    unique_links["$link"]=""
  done

done

# Prepare a list of all files in the wiki folder (excluding hidden folders and .)
all_files=($(find "$wiki_folder" -type f -name "*" ! -path "*/.*" ! -name "."))

# Loop through all files and check if referenced in unique_links
unreferenced_files=()
for file in "${all_files[@]}"; do
  relative_file=$(realpath --relative-to="$wiki_folder" "$file")
  filename="${file##*/}"  # Extract filename from path

  # Check for specific reference rules
  if [[ "$filename" == "README.md" ]]; then
    # Check reference for directory containing README.md
    ref_file="${relative_file%/*}"
  elif [[ "${filename}" =~ \.md$ ]]; then
    # Check reference for the file itself (without .md extension)
    ref_file="${relative_file%.*}"
  else
    # Use existing logic for other files
    ref_file="$relative_file"
  fi

  if [[ ! " ${!unique_links[@]} " =~ " $ref_file " ]]; then
    unreferenced_files+=("$relative_file")
  fi
done

# Print any unreferenced files
if [[ ${#unreferenced_files[@]} -gt 0 ]]; then
  echo "Unreferenced Files:"
  printf "%s\n" "${unreferenced_files[@]}"
fi

# Print the final list of unique links with relative directory (sorted)
echo "Unique Links with Relative Directory Across All Markdown Files (Sorted):"
printf "%s\n" "${!unique_links[@]}" | sort

cd -
