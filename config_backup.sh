#!/bin/bash

# ==== Configuration ==========================================================


# Your repository for config backups
GITHUB_BACKUP_REPO="GITHUB_BACKUP_REPO"

# Paths or glob patterns to backup
PATHS_TO_BACKUP=(
    "$HOME/.config/Code/User/keybindings.json"
    "$HOME/.config/Code/User/settings.json"
    "$HOME/.config/Code/User/snippets"
    "$HOME/.config/Code/User/tasks.json"
    "$HOME/.zshrc"
    "$HOME/config_backup.sh"
    # Add more paths here
)

# Temporary directory. It will be removed after script runs.
BACKUP_DIR_NAME="$HOME/config_backups"

MAX_PUSH_ATTEMPTS=3  # Number of attempts git will try to push if fails


# =============================================================================



# Function to display an alert popup
show_alert() {
    message="$1"
    # Check if the "zenity" command is available and if a display is available
    if command -v zenity &>/dev/null && [ -n "$DISPLAY" ]; then
        zenity --info --text="$message" --title="Backup Script"
    else
        echo "$message"
    fi
}

mkdir -p "$BACKUP_DIR_NAME" || { show_alert "Failed to create temporary backup directory ($BACKUP_DIR_NAME)"; exit 1; }

cd "$BACKUP_DIR_NAME" || { show_alert "Failed to enter temporary backup directory ($BACKUP_DIR_NAME)"; exit 1; }

# Initialize Git in the backup directory
git init || { show_alert "Failed to initialize Git."; exit 1; }
git remote add origin "$GITHUB_BACKUP_REPO" || { show_alert "Failed to add remote."; exit 1; }

# Check if master branch exists on remote
if [ $(git ls-remote --heads origin refs/heads/master | wc -l) -gt 0 ]; then
    git pull origin master || { show_alert "Failed pull from repo."; exit 1; }
fi

# Copy files to backup directory
for path in "${PATHS_TO_BACKUP[@]}"; do
    rsync -av --relative "$path" . || { show_alert "Failed to copy $path to temporary backup directory ($BACKUP_DIR_NAME)"; exit 1; }
done

# Check for changes
if [ $(git status --porcelain | wc -l) -gt 0 ]; then
    # Add all files to Git
    git add . || { show_alert "Failed to add files to Git."; exit 1; }
    TIMESTAMP=$(date +"%Y.%m.%d %H:%M:%S")
    git commit -m "Backup created on $TIMESTAMP" || { show_alert "Failed to commit changes."; exit 1; }

    # Push to GitHub with retries
    attempts=0
    while [ "$attempts" -lt "$MAX_PUSH_ATTEMPTS" ]; do
        if git push -u origin master; then
            break
        else
            attempts=$((attempts + 1))
            show_alert "Pushing to GitHub failed (Attempt $attempts). Retrying in 30 seconds..."
            sleep 30
        fi
    done
else
    echo "Nothing to commit"
fi

# Clean up the temporary backup directory
cd ..
rm -rf "$BACKUP_DIR_NAME"

# Add the cron task to run the script daily
CRON_JOB="0 0 * * * /bin/bash $HOME/backup_script.sh"

if crontab -l &>/dev/null; then
    if ! crontab -l | grep -q "$CRON_JOB"; then
        echo "Cron job already exists. No changes made."
    else
        (crontab -l ; echo "$CRON_JOB") | crontab -
        show_alert "Cron job added."
    fi
else
    echo "$CRON_JOB" | crontab -
    show_alert "Created crontab file and added cron job."
fi
