#!/bin/zsh

# Creates and/or activates a Python virtual environment.
#
# If a virtual environment with the specified name (or "venv" by default)
# does not exist in the current directory, it prompts the user to create one.
# After ensuring the environment exists, it activates it.
# Finally, it calls `upgrade_and_install_pip_modules` to upgrade pip and
# install 'black' and 'mypy'.
#
# Usage: venv [custom_venv_name]
function venv {
    local target_venv

    # Ensure spinner is stopped when the function returns or is interrupted.
    # This trap is local to the function's execution in zsh.
    # It handles normal return, Ctrl+C (INT), TERM, and shell exit.
    trap '_spinner_stop' INT TERM EXIT

    target_venv=${1:-venv}

    local target_folder="./$target_venv"
    if [ ! -d "$target_folder" ]; then
        echo "$target_folder folder does not exist. Create? (y/N)"
        read -r create_env # Use -r to prevent backslash interpretation

        case $create_env in
            Y|y)
                _spinner_start "Creating Python virtual environment '$target_venv'..."
                # Capture command output to prevent interference with the spinner.
                # Output will be shown if an error occurs.
                local venv_output
                venv_output=$(python3 -m venv "$target_venv" 2>&1)
                local venv_status=$?
                _spinner_stop # Stop spinner for this specific operation

                if [ $venv_status -ne 0 ]; then
                    echo "Error creating virtual environment '$target_venv':"
                    echo "$venv_output"
                    return 1 # Trap will call _spinner_stop again (harmless)
                fi
                echo "Virtual environment '$target_venv' created."
                ;;
            *)
                echo "Not creating venv $target_venv. Exiting."
                return 0
                ;;
        esac
    fi


    echo "Activating..."
    source "./$target_venv/bin/activate"
    if [ $? -ne 0 ]; then
        echo "Failed to activate virtual environment '$target_venv'."
        return 1 # Trap will ensure spinner cleanup
    fi

    _spinner_start "Updating pip and installing packages (black, mypy)..."
    upgrade_and_install_pip_modules black mypy
    _spinner_stop

    echo "Setup complete for '$target_venv'."
}

# Upgrades pip and installs specified Python modules.
#
# This function first upgrades pip to the latest version quietly.
# Then, it iterates through the provided arguments (module names) and installs them.
#
# Usage: upgrade_and_install_pip_modules module1 module2 ...
# Example: upgrade_and_install_pip_modules requests numpy
function upgrade_and_install_pip_modules {
    # The spinner is managed by the calling function (venv).

    if ! pip install --upgrade pip -q --disable-pip-version-check; then
        # Print warning on a new line so it's not immediately overwritten by spinner.
        printf "\nWarning: Failed to upgrade pip.\n"
    fi

    if [ "$#" -gt 0 ]; then
        # Add -q to suppress "Requirement already satisfied" and other routine messages.
        # Errors will still cause a non-zero exit code and be caught by the if condition.
        if ! pip install -q "$@"; then
            printf "\nWarning: Some packages may not have installed correctly.\n"
        fi
    fi
 }
