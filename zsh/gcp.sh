# Switches the active Google Cloud Project and optionally re-authenticates.
#
# This function allows you to switch your active gcloud project. It will:
# 1. Display the current project.
# 2. If the target project is already selected, it exits.
# 3. Prompt to confirm switching to the new project.
# 4. Prompt to re-authenticate with gcloud.
# 5. If re-authentication is chosen, it runs `gcloud auth login` and `gcloud auth application-default login`.
# 6. If switching is confirmed, it sets the new project using `gcloud config set project`
#    and `gcloud auth application-default set-quota-project`.
# 7. If switching fails, it offers another chance to re-authenticate and retry.
#
# Usage: switch-project <new-project-id>
function switch-project {
    local current=$(gcloud config get project)
    local newProject=$1
    local reauthMessage="Re-auth? (y/N)"
    local switchProjectMessage="Switch to: $newProject? (Y/n)"

    # Helper function to display a message and read user input into a variable.
    # $1: Message to display.
    # $2: Variable name to store the input.
    function readInput() {
        echo $1
        read $2
    }

    # Evaluates the user's response to the re-authentication prompt.
    # If the user confirms (Y/y), it calls the `authenticate` function.
    # Otherwise, it prints a message indicating no re-authentication will occur.
    function evalReauth() {
        case $reauth in
        Y|y)
            authenticate
            ;;
        *)
            echo "Not re-authenticating"
            ;;
        esac
    }

    # Handles the gcloud authentication process.
    function authenticate() {
        echo "Re-authenticating..."
        gcloud auth login
        gcloud auth application-default login
    }

    # Handles the logic for switching the gcloud project.
    function switch() {
        echo "Switching..."
        gcloud config set project "$newProject"
        gcloud auth application-default set-quota-project "$newProject"

        if [ $? != 0 ]; then
            echo "Project switching failed..."
            readInput $reauthMessage reauth
            evalReauth
            if [ $reauth ]; then
                switch
            else
                echo "Aborting."
            fi
        fi
    }

    echo "Current project: $current"
    if [ $current = $newProject ]; then
        echo "Project already selected"
        return 0
    fi

    readInput "$switchProjectMessage" switchproj
    readInput "$reauthMessage" reauth

    evalReauth

    case $switchproj in
        Y|y|"")
            switch
            ;;
        *)
            echo "Not switching."
            ;;
    esac
}
