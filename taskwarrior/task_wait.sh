#!/usr/bin/env bash
# Set a task to wait until a given duration (taskwarrior-tui shortcut script).
# Usage:
#   task_wait.sh <task_uuid> <duration>
# Examples: task_wait.sh <uuid> 1d   task_wait.sh <uuid> 1week
#
# For taskwarrior-tui shortcuts, the tui only passes the selected task UUID.
# To pass a duration "when defining the shortcut", use a small wrapper that
# calls this script with the duration, e.g. in .taskrc:
#   uda.taskwarrior-tui.shortcuts.4=~/.dotfiles/taskwarrior/task_wait_1d.sh
# and task_wait_1d.sh contains:
#   #!/usr/bin/env bash
#   exec "$(dirname "$0")/task_wait.sh" "$1" 1d

set -e
task_uuid="$1"
duration="$2"

if [[ -z "$task_uuid" || -z "$duration" ]]; then
  echo "Usage: $0 <task_uuid> <duration>" >&2
  echo "Example: $0 <uuid> 1d" >&2
  exit 1
fi

task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off "$task_uuid" mod "wait:${duration}"
