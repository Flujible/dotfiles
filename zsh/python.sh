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

    # if $1 exists, use it, otherwise use "venv"
    target_venv=${1:-venv}

    local target_folder="./$target_venv"
    if [ ! -d "$target_folder" ]; then
        echo "$target_folder folder does not exist. Create? (y/N)"
        read create_env

        case $create_env in
            Y|y)
                echo "Creating..."
                python3 -m venv $target_venv
                ;;
            *)
                echo "Not creating venv $target_venv. Exiting."
                return 0
                ;;
        esac
    fi


    echo "Activating..."
    source ./$target_venv/bin/activate

    upgrade_and_install_pip_modules black mypy
}

# Upgrades pip and installs specified Python modules.
#
# This function first upgrades pip to the latest version quietly.
# Then, it iterates through the provided arguments (module names) and installs them.
#
# Usage: upgrade_and_install_pip_modules module1 module2 ...
# Example: upgrade_and_install_pip_modules requests numpy
function upgrade_and_install_pip_modules {
    echo "Upgrading pip..."
    pip install --upgrade pip -q

    echo "Installing modules:"
    for module in "$@"; do
        echo "- $module"
    done

    pip install "$@"
}
