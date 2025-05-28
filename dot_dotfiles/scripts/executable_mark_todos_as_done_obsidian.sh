#!/./bin/bash

folder_path="$HOME/Documents/Ancoris Vault"
exclude_files=(
    "$HOME/Documents/Ancoris Vault/BuJo/Formatting reference.md"
)

find "$folder_path" \
  \( -path "$HOME/Documents/Ancoris Vault/.obsidian" -prune \) -o \
  \( -path "$HOME/Documents/Ancoris Vault/.trash" -prune \) -o \
  \( -path "$HOME/Documents/Ancoris Vault/Excalidraw/Scripts" -prune \) -o \
  \( -path "$HOME/Documents/Ancoris Vault/Templates" -prune \) -o \
  \( -type f -name "*.md" \) | while read -r file; do
    # Check if the file is in the exclusion list
    if [[ " ${exclude_files[*]} " =~ " ${file} " ]]; then
      echo "Skipping excluded file: $file"
      continue
    fi

    # Check if $file is a regular file
    if [[ ! -f "$file" ]]; then
      echo "Skipping: $file is not a regular file"
      continue
    fi

    echo "Processing file: $file"
    # sed -i '' -- 's/* \[/- [/' "$file" # Switch any asterisk based tasks to dash based tasks
    sed -i '' -- 's/- \[ \]/- [x]/' "$file"
    sed -i '' -- 's/- \[\/\]/- [x]/' "$file"

    complete_calendar_based_tasks=true
    if $complete_calendar_based_tasks; then
        sed -i '' -- 's/- \[\>\]/- [x]/' "$file"
        sed -i '' -- 's/- \[\<\]/- [x]/' "$file"
    fi
done
