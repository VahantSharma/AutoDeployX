#!/bin/bash

# Set the log file locations and email settings
LOG_FILE="backup_log.txt"
ERROR_LOG_FILE="backup_error_log.txt"
EMAIL_NOTIFICATION="samvanrocks12315@gmail.com"

# Function to log messages with timestamps and log type (INFO or ERROR)
log_message() {
    local message=$1
    local log_type=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [ "$log_type" == "ERROR" ]; then
        echo "$timestamp - ERROR: $message" >> "$ERROR_LOG_FILE"
    else
        echo "$timestamp - INFO: $message" >> "$LOG_FILE"
    fi
}

# Function to send an email notification using msmtp for gmail
send_email_notification() {
    local subject=$1
    local body=$2
    local temp_email=$(mktemp)

    # Prepare the email content
    echo "Subject: $subject" > "$temp_email"
    echo "" >> "$temp_email"
    echo "$body" >> "$temp_email"

    # Send the email using msmtp
    msmtp "$EMAIL_NOTIFICATION" < "$temp_email"

    # Check if msmtp command was successful
    if [ $? -eq 0 ]; then
        log_message "Email notification sent to $EMAIL_NOTIFICATION: $subject" "INFO"
    else
        log_message "Failed to send email notification to $EMAIL_NOTIFICATION." "ERROR"
    fi

    # Clean up temporary email file
    rm -f "$temp_email"
}

# Function to clean up old backups (older than 7 days)
cleanup_old_backups() {
    local backup_dir=$1
    find "$backup_dir" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;
    log_message "Cleaned up backups older than 7 days in $backup_dir." "INFO"
}

# Function to ensure the destination directory exists vrna create kr dega
createDestDir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_message "Created destination directory: $dir" "INFO"
    fi
}

# Main backup function
backup_files() {
    read -p "Enter the source directory to back up: " sourceDir
    read -p "Enter the destination directory: " destDir
    read -p "Do you want to compress the backup? (yes/no): " compress
    read -p "Would you like to receive email notifications on success or failure? (yes/no): " emailNotification

    if [ ! -d "$sourceDir" ]; then
        log_message "Source directory $sourceDir does not exist." "ERROR"
        echo "Source directory does not exist. Exiting."
        [ "$emailNotification" == "yes" ] && send_email_notification "Backup Failed" "Source directory $sourceDir does not exist."
        exit 1
    fi

    createDestDir "$destDir"
    backupNameGenerator=$(basename "$sourceDir")_backup_$(date '+%Y%m%d_%H%M%S')

    if [ "$compress" == "yes" ]; then
        backup_file="$destDir/$backupNameGenerator.tar.gz"
        tar -czf "$backup_file" -C "$sourceDir" .
        if [ $? -eq 0 ]; then
            log_message "Compressed backup created: $backup_file" "INFO"
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Backup $backup_file created successfully."
        else
            log_message "Failed to create compressed backup: $backup_file" "ERROR"
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Failed" "Failed to create compressed backup $backup_file."
            exit 1
        fi
    else
        backup_dir="$destDir/$backupNameGenerator"
        cp -r "$sourceDir"/* "$backup_dir"
        if [ $? -eq 0 ]; then
            log_message "Backup copied to $backup_dir" "INFO"
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Files successfully copied to $backup_dir."
        else
            log_message "Failed to copy files to $backup_dir" "ERROR"
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Failed" "Failed to copy files to $backup_dir."
            exit 1
        fi
    fi

    cleanup_old_backups "$destDir"
    log_message "Backup operation completed successfully." "INFO"
    [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Backup completed successfully!"
}

# Run the main backup function
backup_files
