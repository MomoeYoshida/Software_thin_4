#!/bin/bash
# Usage: ./submit_extract_night_gridcount_jobs.sh 20250111 20250331
# Submits one PBS job per day in the range, using Julian day numbering (001–365/366)

start_date="$1"
end_date="$2"

if [ -z "$start_date" ] || [ -z "$end_date" ]; then
    echo "Usage: $0 <start_date: YYYYMMDD> <end_date: YYYYMMDD>"
    exit 1
fi

# Convert YYYYMMDD to epoch seconds
start_sec=$(date -d "$start_date" +%s)
end_sec=$(date -d "$end_date" +%s)

current_sec=$start_sec

while [ "$current_sec" -le "$end_sec" ]; do
    # Extract current year and Julian day (e.g., 2025 011)
    year=$(date -d "@$current_sec" +%Y)
    day=$(date -d "@$current_sec" +%j)

    echo "📤 Submitting job for Year=${year}, JulianDay=${day} "

    # Submit PBS job with variables
    qsub -v year=$year,day=$day extract_night_gridcount.pbs

    # Pause briefly to avoid scheduler overload
    sleep 1

    # Advance by one day
    current_sec=$((current_sec + 86400))
done
