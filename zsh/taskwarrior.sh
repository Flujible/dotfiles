#!/bin/zsh

function tw-switch {
    local personal_task_dir="$HOME/.task.personal"
    local work_task_dir="$HOME/.task"
    local target_context="$1"

    if [[ -n "$target_context" ]]; then # Check if an argument is provided
        if [[ "$target_context" == "personal" ]]; then
            export TASKDATA="$personal_task_dir"
            echo "Switched to Taskwarrior context: personal (TASKDATA=$TASKDATA)"
        elif [[ "$target_context" == "work" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Switched to Taskwarrior context: work (TASKDATA=$TASKDATA)"
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
            echo "Toggled Taskwarrior context to: personal (TASKDATA=$TASKDATA)"
        elif [[ "$expanded_current_taskdata" == "$personal_task_dir" ]]; then
            export TASKDATA="$work_task_dir"
            echo "Toggled Taskwarrior context to: work (TASKDATA=$TASKDATA)"
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
