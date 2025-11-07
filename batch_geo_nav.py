#!/usr/bin/env python3
import os
import subprocess
from netCDF4 import Dataset
from datetime import datetime

DATA_DIR = "../Data"
SCRIPT = "./geo_nav.py"

# NAME:
# 	batch_geo_nav
# 
# DESCRIPTION:
# 	Adds lat/lon to the files which don't have lat/lon in DATA_DIR.
#
# USAGE:
#	python3 batch_geo_nav.py yyyymmdd yyyymmdd

def has_latlon(nc_path):
    """Check if a NetCDF file contains lat/lon variables."""
    try:
        with Dataset(nc_path, 'r') as ds:
            vars_lower = [v.lower() for v in ds.variables.keys()]
            return "lat" in vars_lower and "lon" in vars_lower
    except Exception as e:
        print(f"⚠️  Error reading {nc_path}: {e}")
        return False

def process_file(nc_path):
    """Run geo_nav.py on the file to add lat/lon."""
    cmd = ["python3", SCRIPT, nc_path]  # overwrite same file
    print(f"🛰️  Processing: {nc_path}")
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error processing {nc_path}: {e}")

def main(start_date=None, end_date=None):
    if start_date and end_date:
	# Convert yyyymmdd string to datetime.date
        start_date = datetime.strptime(start_date, "%Y%m%d").date()
	end_date = datetime.strptime(end_date, "%Y%m%d").date()
	print(f"📅 Processing files between {start_date} and {end_date}")
    else:
	print("⚠️ No date range specified — processing all files")
    for root, _, files in os.walk(DATA_DIR):
        for f in files:
            if f.endswith(".nc"):
		continue
	    # Extract date from filename (first 8 chars)
	    file_date = datetime.strptime(f[:8], "%Y%m%d").date()
	    # Skip files outside the range (if range specified)
            if start_date and end_date and not (start_date <= file_date <= end_date):
                continue
	    path = os.path.join(root, f)
	    if has_latlon(path):
                print(f"⏩ Skipping {path} (already has lat/lon)")
                continue
            process_file(path)

    print("\n✅ All eligible files processed!")

if __name__ == "__main__":
    # Date range to process is defined
    if len(sys.argv) == 3:
	main(sys.argv[1],sys.argv[2])
    else:
	main()
