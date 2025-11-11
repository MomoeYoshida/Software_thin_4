#!/bin/bash
# Usage: ./submit_generate_oi_input_data_single_jobs.sh 20250111 20250331
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

    # Yesterday (handles year rollover automatically)
    yyear=$(date -d "@$((current_sec - 86400))" +%Y)
    yday=$(date -d "@$((current_sec - 86400))" +%j)

    echo "📤 Submitting job for Year=${year}, JulianDay=${day} (yesterday: ${yyear}-${yday})"

    # Submit PBS job with variables
    qsub -v year=$year,day=$day,yyear=$yyear,yday=$yday generate_oi_input_data_single.pbs

    # Pause briefly to avoid scheduler overload
    sleep 1

    # Advance by one day
    current_sec=$((current_sec + 86400))
done
