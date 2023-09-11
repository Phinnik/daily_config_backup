# Back up configuration files to github daily

## Usage:
1. Put [config_backup.sh](https://github.com/Phinnik/daily_config_backup/blob/master/config_backup.sh) to $HOME/config_backup.sh
2. Configure the script:
    - Fill in url to your github repo
    - Provide paths and glob patterns for backup
    - If needed: rename temporary backup directory
3. Make the script executable: `chmod +x $HOME/config_backup.sh`
4. Run script: `./config_backup.sh`

## How does it work?
1. Create temp directory
2. Copy "backuped" files
3. Init repository, push if there are any changes.
4. Remove temp directory
5. Create cron task to backup daily


Если происходят ошибки, вы увидите: всплывет сообщение.
## PRO TIPS
- Do not back up full "$HOME/.config" directory. Some applications use it for cache :clown:
- Star this repo, write issues, make contributions



## Test:
1. Configure script with your test repository
2. 
    ```bash
    docker build -t backup_test --build-arg="GITHUB_USERNAME=YOUR_GITHUB_USERNAME" --build-arg="YOUR_GITHUB_EMAIL=GITHUB_EMAIL" .
    docker run -it -v ~/.ssh:/root/.ssh -e SSH_AUTH_SOCK="$SSH_AUTH_SOCK" backup_test
    ```
