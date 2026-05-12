#!/usr/bin/env python3
import sys
import json
from datetime import datetime, timezone

# --- CONFIGURATION ---
# The default time you want to set (24-hour format)
DEFAULT_HOUR = 17
DEFAULT_MINUTE = 30

# Taskwarrior's internal UTC date format
TW_FORMAT = "%Y%m%dT%H%M%SZ"


def process_task(task):
    # Check due dates, but also wait, scheduled, or until dates if you use them
    for field in ['due', 'wait', 'scheduled', 'until']:
        if field in task:
            # 1. Parse the UTC time string from Taskwarrior
            utc_dt = datetime.strptime(task[field], TW_FORMAT)
            utc_dt = utc_dt.replace(tzinfo=timezone.utc)

            # 2. Convert to local system time
            local_dt = utc_dt.astimezone()

            # 3. Check if the time is exactly 00:00:00 (midnight local time)
            if local_dt.hour == 0 and local_dt.minute == 0 and local_dt.second == 0:

                # 4. Update the time to 17:30 local time
                local_dt = local_dt.replace(hour=DEFAULT_HOUR, minute=DEFAULT_MINUTE)

                # 5. Convert back to UTC and save it into the task dictionary
                new_utc_dt = local_dt.astimezone(timezone.utc)
                task[field] = new_utc_dt.strftime(TW_FORMAT)

    return task


def main():
    # Read the raw JSON from Taskwarrior via standard input
    input_lines = sys.stdin.read().splitlines()
    if not input_lines:
        sys.exit(0)

    # on-add passes 1 line. on-modify passes 2 lines (old state, new state).
    # We always want to evaluate the last line (the newest state of the task).
    task = json.loads(input_lines[-1])

    modified_task = process_task(task)

    # Print the modified JSON back to Taskwarrior via standard output
    print(json.dumps(modified_task))
    sys.exit(0)


if __name__ == "__main__":
    main()
