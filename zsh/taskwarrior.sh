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
