#!/bin/zsh

function tw-switch {
    local personal_task_dir="$HOME/.task.personal"
    local work_task_dir="$HOME/.task"
    local target_context="$1"
    local pink_bold_style='\e[1;95m' # 1 for bold, 95 for bright magenta (pink)
    local reset_colour='\e[0m'

    if [[ -n "$target_context" ]]; then # Check if an argument is provided
        if [[ "$target_context" == "personal" ]]; then
            export TASKDATA="$personal_task_dir"
            echo "Switched to Taskwarrior context: ${pink_bold_style}PERSONAL${reset_colour} (TASKDATA=$TASKDATA)"
        elif [[ "$target_context" == "work" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Switched to Taskwarrior context: ${pink_bold_style}WORK${reset_colour} (TASKDATA=$TASKDATA)"
        else
            echo "Error: Invalid argument '$target_context'." >&2
            echo "Usage: tw-switch [personal|work]" >&2
            echo "       (no argument toggles between contexts and defaults to work if current is unknown)" >&2
            return 1
        fi
    else
        # Toggle logic
        local current_taskdata_val_orig="$TASKDATA" # Original value for messages
        # Expand ~ in current_taskdata_val if it exists, for robust comparison.
        # If TASKDATA is unset, expanded_current_taskdata will be empty.
        local expanded_current_taskdata="${current_taskdata_val_orig/#\~/$HOME}"

        if [[ "$expanded_current_taskdata" == "$work_task_dir" ]]; then
            export TASKDATA="$personal_task_dir"
            echo "Toggled Taskwarrior context to: ${pink_bold_style}PERSONAL${reset_colour} (TASKDATA=$TASKDATA)"
        elif [[ "$expanded_current_taskdata" == "$personal_task_dir" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Toggled Taskwarrior context to: ${pink_bold_style}WORK${reset_colour} (TASKDATA=$TASKDATA)"
        else
            # Default to work if current state is unknown or unset
            export TASKDATA="$work_task_dir"
            if [[ -z "$current_taskdata_val_orig" ]]; then
                echo "TASKDATA was not set. Defaulting to Taskwarrior context: work (TASKDATA=$TASKDATA)"
            else
                echo "Current TASKDATA ('$current_taskdata_val_orig') is not a recognized context. Defaulting to Taskwarrior context: work (TASKDATA=$TASKDATA)"
            fi
        fi
    fi
    return 0 # Indicate success
}

function tw-list {
    local personal_task_dir="$HOME/.task.personal"
    local work_task_dir="$HOME/.task"
    local output_str="Current taskwarrior DB:"
    local pink_bold_style='\e[1;95m' # 1 for bold, 95 for bright magenta (pink)
    local reset_colour='\e[0m'

    if [[ "$TASKDATA" == "$work_task_dir" ]]; then
        echo "$output_str ${pink_bold_style}WORK${reset_colour} ($TASKDATA)"
    elif [[ "$TASKDATA" == "$personal_task_dir" ]]; then
        echo "$output_str ${pink_bold_style}PERSONAL${reset_colour} ($TASKDATA)"
    else
        echo "$output_str ${pink_bold_style}UNKNOWN${reset_colour} ($TASKDATA)"
    fi
}

function tw-create-contexts {
    # This script creates Taskwarrior contexts for each project,
    # ensuring idempotency (no duplicate contexts are created).

    TASKRC_PATH="$HOME/.taskrc"

    echo "Starting Taskwarrior project context creation..."
    echo "Checking projects from 'task _projects'..."

    # Get all unique project names from Taskwarrior, one per line.
    projects=$(task _projects | sort | uniq)

    # Check if task _projects returned any output
    if [[ -z "$projects" ]]; then
    echo "No projects found in Taskwarrior. Exiting."
    exit 0
    fi

    # Read projects line by line
    # IFS= read -r prevents leading/trailing whitespace issues and backslash interpretation.
    while IFS= read -r project; do
        # Skip empty lines that might result from `task _projects` output
        if [[ -z "$project" ]]; then
            continue
        fi

        # Sanitize the project name for use as a context name.
        # Replaces spaces and non-alphanumeric characters with underscores.
        context_name=$(echo "$project" | sed 's/[^a-zA-Z0-9]/_/g')

        # Construct the expected context definition string to search for in .taskrc.
        # We look for 'context.SanitizedProjectName=project:"Original Project Name"'
        # The `grep -F` makes it search for a fixed string, not a regex.
        # The `grep -q` makes it quiet, only returning a status code.
        # This check directly verifies if the exact context definition line exists in .taskrc.
        if grep -F "context.$context_name.read=project:$project" "$HOME/.taskrc"; then
            echo "Context (read) for project '$project' (as '$context_name') already exists. Skipping."
        else
            # Pipe `yes` into the command to accept all the prompts
            echo "Adding new context for project '$project' (as '$context_name')..."
            yes | task context define "$context_name" project:"$project"
            echo "Context '$context_name' added successfully."
        fi
    done <<< "$projects" # Use a 'here string' to feed the projects variable into the while loop

    echo "Taskwarrior context creation complete."
}

function tw-import-markdown {
    local markdown_file="$1"
    local pink_bold_style='\e[1;95m'
    local reset_colour='\e[0m'

    if [[ ! -f "$markdown_file" ]]; then
        echo "Error: File '$markdown_file' does not exist." >&2
        return 1
    fi

    # Create a temporary file to store task IDs and their indentation levels
    local temp_file=$(mktemp)
    local task_id_map=()

    echo "Processing markdown file: ${pink_bold_style}$markdown_file${reset_colour}"
    echo "Creating tasks..."

    # First pass: Create all tasks and store their IDs
    while IFS= read -r line; do
        # Skip empty lines and non-bullet points
        if [[ ! "$line" =~ ^[[:space:]]*-[[:space:]]* ]]; then
            continue
        fi

        # Calculate indentation level (number of spaces before the bullet)
        local indent=$(echo "$line" | sed -E 's/^([[:space:]]*)-.*/\1/' | wc -c)
        local indent=$((indent - 1))  # Adjust for the newline character

        # Extract the task description (remove the bullet and leading/trailing spaces)
        local description=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]*//')

        # Create the task and store its ID
        local task_id=$(task add "$description" | grep -o '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}' | head -n1)
        if [[ -n "$task_id" ]]; then
            echo "$task_id:$indent" >> "$temp_file"
            task_id_map+=("$task_id:$indent")
            echo "Created task $task_id: $description"
        fi
    done < "$markdown_file"

    # Second pass: Set up dependencies
    echo "Setting up dependencies..."
    local -a task_ids=()
    local -a indent_levels=()

    # Read the temporary file and create arrays
    while IFS=: read -r task_id indent; do
        task_ids+=("$task_id")
        indent_levels+=("$indent")
    done < "$temp_file"

    # Process tasks in reverse order to set up dependencies
    for ((i=${#task_ids[@]}-1; i>=0; i--)); do
        local current_id="${task_ids[$i]}"
        local current_indent="${indent_levels[$i]}"

        # Look for the next task with a lower indentation level
        for ((j=i-1; j>=0; j--)); do
            if [[ "${indent_levels[$j]}" -lt "$current_indent" ]]; then
                # Found a parent task, set up the dependency
                echo "Setting dependency: task $current_id depends on task ${task_ids[$j]}"
                task "${task_ids[$j]}" modify depends:"$current_id"
                if [[ $? -eq 0 ]]; then
                    echo "Successfully set dependency"
                else
                    echo "Failed to set dependency for task $current_id"
                fi
                break
            fi
        done
    done

    # Clean up
    rm "$temp_file"
    echo "Import complete!"
}

function tw-remove-dependencies {
    local pink_bold_style='\e[1;95m'
    local reset_colour='\e[0m'
    local filter_cmd="$1"

    if [[ -z "$filter_cmd" ]]; then
        echo "Error: No filter command provided." >&2
        echo "Usage: tw-remove-dependencies <filter_command>" >&2
        echo "Example: tw-remove-dependencies ''" >&2
        echo "Example: tw-remove-dependencies 'project:Work'" >&2
        return 1
    fi

    echo "Removing dependencies from tasks matching: ${pink_bold_style}$filter_cmd${reset_colour}"

    # Get all task IDs from the filtered command
    local task_ids=($(task $filter_cmd _ids))

    if [[ ${#task_ids[@]} -eq 0 ]]; then
        echo "No tasks found matching the filter."
        return 0
    fi

    local count=0
    for task_id in "${task_ids[@]}"; do
        # Check if the task has any dependencies
        if task "$task_id" _get depends >/dev/null 2>&1; then
            echo "Removing dependencies from task $task_id"
            task "$task_id" modify depends:
            if [[ $? -eq 0 ]]; then
                ((count++))
            fi
        fi
    done

    echo "Removed dependencies from ${pink_bold_style}$count${reset_colour} tasks."
}
