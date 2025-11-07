#!/usr/bin/env python3
import os
import subprocess
from netCDF4 import Dataset

DATA_DIR = "../Data"
SCRIPT = "./geo_nav.py"

# NAME:
# 	batch_geo_nav
# 
# DESCRIPTION:
# 	Adds lat/lon to the files which don't have lat/lon in DATA_DIR.
#

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

def main():
    for root, _, files in os.walk(DATA_DIR):
        for f in files:
            if f.endswith(".nc"):
                path = os.path.join(root, f)
                if has_latlon(path):
                    print(f"⏩ Skipping {path} (already has lat/lon)")
                    continue
                process_file(path)

    print("\n✅ All eligible files processed!")

if __name__ == "__main__":
    main()
