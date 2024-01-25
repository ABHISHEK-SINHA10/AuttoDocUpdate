#!/bin/bash

# Replace 'path/to/directory' with the actual path to your directory
directory_path="/root/.ansible/collections/ansible_collections/dellemc/openmanage/tests/integration/targets"

# Changing directory
cd "$directory_path"

# Get the names of the immediate level 1 folders
folder_names=$(ls -d "$directory_path"/*)

# Get the basename of each folder
for folder in $folder_names
    do basename=$(basename "$folder")
    doc_path="$directory_path/$basename/tests/ansible_doc.yaml"
    meta_path="$directory_path/$basename/meta"
    if [ -d "$meta_path" ]; then
      file_path="$meta_path/main.yaml"
      # Adding # to the beginning of each line
      sed -i 's/^/#/' "$file_path"
    fi

    if [ -f "$doc_path" ]; then
      #### Changing check mode to false before generating doc ####
      sed -i 's/check_mode: true/check_mode: false/g' "$doc_path"

      # Run ansible command to generate doc
      ansible-test network-integration "$basename" --testcase ansible_doc -vvvv --no-temp-workdir > /dev/null

      #### Changing check mode to true after generating doc ####
      sed -i 's/check_mode: false/check_mode: true/g' "$doc_path"
    fi

    if [ -d "$meta_path" ]; then
      file_path="$meta_path/main.yaml"
      # Removing # from the beginning of the line
      sed -i 's/^#//' "$file_path"
    fi

    echo "$basename"
done
