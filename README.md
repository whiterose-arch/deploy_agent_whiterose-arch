# Attendance Tracker Lab

This is my Linux lab project. It sets up a small attendance tracking system using a bash script and a Python script.

## What it does

The setup script creates a project folder with:
- a Python script that reads student attendance from a CSV file
- a config file for warning/failure thresholds
- a reports folder where alerts get logged

Students below the failure threshold get an urgent message. Students below the warning threshold get a warning.

## Requirements

- Linux
- Bash
- Python 3

## How to run

1. Make the setup script executable:
   ```
   chmod +x setup_project.sh
   ```

2. Run it with your name or student id:
   ```
   ./setup_project.sh yourname
   ```

   This creates a folder called `attendance_tracker_yourname`.

3. Go into that folder and run the checker:
   ```
   cd attendance_tracker_yourname
   python3 attendance_checker.py
   ```

4. When you're done, press `Ctrl+C` in the setup terminal. The script will archive the project into a `.tar.gz` file.

## Project structure

```
attendance_tracker_yourname/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## Config

The config file is in `Helpers/config.json`. You can change:
- `warning` - attendance % for warnings (default 75)
- `failure` - attendance % for failure alerts (default 50)
- `run_mode` - use `"live"` to write to the log, or something else for dry run
- `total_sessions` - total number of classes

The setup script also asks you for warning and failure values when you first run it.
