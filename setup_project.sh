#!/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME="attendance_tracker_$1"
HELPERS_DIR="$PROJECT_NAME/Helpers"
REPORTS_DIR="$PROJECT_NAME/reports"

ARCHIVE_DIR="attendance_tracker_$1_archive"

handle_archive() {
    if [ -d "$ARCHIVE_DIR" ]; then
        rm -rf "$ARCHIVE_DIR"
    fi
    
    if [ ! -d "$PROJECT_NAME" ]; then
        echo "Project directory does not exist. Please run ./setup_project.sh $1 again."
        exit 1
    fi

    tar -czvf "$ARCHIVE_DIR.tar.gz" "$PROJECT_NAME"
    rm -rf "$PROJECT_NAME"

    echo "Project directory archived."
    exit 0
}

# archive project when interrupted
trap handle_archive SIGINT

# Create the parent directory
mkdir -p "$PROJECT_NAME"

# Create the helpers and reports directories
mkdir -p "$HELPERS_DIR"
mkdir -p "$REPORTS_DIR"

# Create the attendance checker script
cat > "$PROJECT_NAME/attendance_checker.py" <<'PYTHON'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYTHON

# Create the assets file
cat > "$HELPERS_DIR/assets.csv" <<'CSV'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSV

# Create the config file
cat > "$HELPERS_DIR/config.json" <<'JSON'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSON

# Create the reports log file
cat > "$REPORTS_DIR/reports.log" <<'LOG'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
LOG

read -p "Enter the threshold warning percentage (default: 75): " WARNING_THRESHOLD
WARNING_THRESHOLD=${WARNING_THRESHOLD:-75}

read -p "Enter the threshold failure percentage (default: 50): " FAILURE_THRESHOLD
FAILURE_THRESHOLD=${FAILURE_THRESHOLD:-50}

sed -i "s/\"warning\": 75/\"warning\": $WARNING_THRESHOLD/" "$HELPERS_DIR/config.json"
sed -i "s/\"failure\": 50/\"failure\": $FAILURE_THRESHOLD/" "$HELPERS_DIR/config.json"

# perform health check

# check if python3 is installed using python3 --version
if ! python3 --version > /dev/null 2>&1; then
    echo "Python3 is not installed. Please install Python3 and try again."
else
    echo "Python3 is installed."
fi

# check if application directory structure is correct
if [ ! -d "$PROJECT_NAME" ]; then
    echo "Project directory does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Project directory exists."
fi

# check if helpers directory exists
if [ ! -d "$HELPERS_DIR" ]; then
    echo "Helpers directory does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Helpers directory exists."
fi

# check if reports directory exists
if [ ! -d "$REPORTS_DIR" ]; then
    echo "Reports directory does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Reports directory exists."
fi

# check if attendance checker script exists
if [ ! -f "$PROJECT_NAME/attendance_checker.py" ]; then
    echo "Attendance checker script does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Attendance checker script exists."
fi

# check if assets file exists
if [ ! -f "$HELPERS_DIR/assets.csv" ]; then
    echo "Assets file does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Assets file exists."
fi

# check if config file exists
if [ ! -f "$HELPERS_DIR/config.json" ]; then
    echo "Config file does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Config file exists."
fi

# check if reports log file exists
if [ ! -f "$REPORTS_DIR/reports.log" ]; then
    echo "Reports log file does not exist. Please run ./setup_project.sh $1 again."
else
    echo "Reports log file exists."
fi
