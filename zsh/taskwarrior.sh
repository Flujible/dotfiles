#!/bin/zsh

function tw-switch {
    local personal_task_dir="$HOME/.task.personal"
    local work_task_dir="$HOME/.task"
    local target_context="$1"
    local pink_bold_style='\e[1;95m' # 1 for bold, 95 for bright magenta (pink)
    local reset_color='\e[0m'

    if [[ -n "$target_context" ]]; then # Check if an argument is provided
        if [[ "$target_context" == "personal" ]]; then
            export TASKDATA="$personal_task_dir"
            echo "Switched to Taskwarrior context: ${pink_bold_style}PERSONAL${reset_color} (TASKDATA=$TASKDATA)"
        elif [[ "$target_context" == "work" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Switched to Taskwarrior context: ${pink_bold_style}WORK${reset_color} (TASKDATA=$TASKDATA)"
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
            echo "Toggled Taskwarrior context to: ${pink_bold_style}PERSONAL${reset_color} (TASKDATA=$TASKDATA)"
        elif [[ "$expanded_current_taskdata" == "$personal_task_dir" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Toggled Taskwarrior context to: ${pink_bold_style}WORK${reset_color} (TASKDATA=$TASKDATA)"
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
    local reset_color='\e[0m'

    if [[ "$TASKDATA" == "$work_task_dir" ]]; then
        echo "$output_str ${pink_bold_style}WORK${reset_color} ($TASKDATA)"
    elif [[ "$TASKDATA" == "$personal_task_dir" ]]; then
        echo "$output_str ${pink_bold_style}PERSONAL${reset_color} ($TASKDATA)"
    else
        echo "$output_str ${pink_bold_style}UNKNOWN${reset_color} ($TASKDATA)"
    fi
}
