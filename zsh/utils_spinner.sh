#!/bin/zsh

# --- Spinner Functions ---
# These functions manage a simple command-line spinner.

# Holds the Process ID of the spinner background job.
_SPINNER_PID=""
# Holds the message displayed next to the spinner.
_SPINNER_MSG=""

# The spinner animation worker function. Runs in the background.
_spinner_job() {
    local sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' # Spinner characters
    local n=${#sp}
    local i=0
    # Consider uncommenting tput lines if you want to hide/show cursor
    # tput civis # Hide cursor

    while :; do # Loop indefinitely
        # Zsh array indexing for characters in a string is 1-based.
        printf "\r%s %s" "${sp[((i++%n)+1)]}" "${_SPINNER_MSG}"
        sleep 0.1
    done
}

# Starts the spinner with an optional message.
_spinner_start() {
    # The `monitor` option is not affected by `local_options` by default in Zsh.
    # We need to manually save and restore its state.

    # If a spinner is already running (e.g., from a previous unclean exit within the script), stop it.
    if [[ -n "$_SPINNER_PID" ]] && kill -0 "$_SPINNER_PID" &>/dev/null; then
        kill "$_SPINNER_PID" &>/dev/null
        wait "$_SPINNER_PID" &>/dev/null
    fi

    _SPINNER_MSG="${1:-Working...}" # Default message if none provided

    local monitor_was_set=0
    # Check if job control (monitor option) is active.
    if [[ -o monitor ]]; then
        monitor_was_set=1
        unsetopt monitor  # Temporarily disable monitor globally to prevent [N] PID message.
    fi

    _spinner_job & # Run the spinner job in the background
    _SPINNER_PID=$! # Store its PID

    # Disown the spinner job so the shell doesn't print a termination message (e.g., "+ done ...").
    disown "$_SPINNER_PID" &>/dev/null

    # Restore the monitor option to its original state.
    if (( monitor_was_set )); then
        setopt monitor
    fi
}

# Stops the currently running spinner.
_spinner_stop() {
    if [[ -n "$_SPINNER_PID" ]] && kill -0 "$_SPINNER_PID" &>/dev/null; then
        # No need to manage monitor state here if _spinner_start disowned properly
        # and the primary concern was shell job messages.
        kill "$_SPINNER_PID" &>/dev/null         # Send TERM signal
        wait "$_SPINNER_PID" &>/dev/null         # Wait for the process to actually terminate
        printf '\r\033[K' # Clear the spinner line
        _SPINNER_PID="" # Reset PID
    fi
}
# --- End Spinner Functions ---
