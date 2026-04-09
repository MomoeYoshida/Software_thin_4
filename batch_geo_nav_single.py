#!/usr/bin/env python3
import os
import subprocess
import sys
from netCDF4 import Dataset
from datetime import datetime
import glob

DATA_DIR = "../Data"
SCRIPT = "./geo_nav.py"
GEO = ["goes","mio","msg","mtsat"]

# NAME:
#	batch_geo_nav
# 
# DESCRIPTION:
#	Adds lat/lon to the files which don't have lat/lon in DATA_DIR.
#
# USAGE:
#	python3 batch_geo_nav.py yyyymmdd

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
	cmd = ["python3", SCRIPT, nc_path]	# overwrite same file
	print(f"🛰️  Processing: {nc_path}")
	try:
		subprocess.run(cmd, check=True)
	except subprocess.CalledProcessError as e:
		print(f"❌ Error processing {nc_path}: {e}")

def main(tar_date=None):
	if tar_date:
	# Convert yyyymmdd string to datetime.date
		tar_date = datetime.strptime(tar_date, "%Y%m%d").date()	
		print(f"📅 Processing files  of {tar_date} ")
	else:
		print("⚠️ No date specified — processing all files")
	for platform in os.listdir(DATA_DIR):
		platform_lower = platform.lower()
		# if not geostationary, skip
		if not any(platform_lower.startswith(g) for g in GEO):
			print(f"Skipping {platform} (not GEO platform)")
			continue
		platform_dir = os.path.join(DATA_DIR, platform)
		if not os.path.isdir(platform_dir):
			continue	# skip non-folder entries
		nc_files = glob.glob(os.path.join(platform_dir, "*.nc"))
		for fpath in nc_files:
			fname = os.path.basename(fpath)
			file_date = datetime.strptime(fname[:8], "%Y%m%d").date()
			# if not that date, skip files
			if tar_date is not None and file_date != tar_date:
				continue
			if has_latlon(fpath):
				print(f"⏩	Skipping {fpath} (already has lat/lon)")
				continue

			process_file(fpath)

	print("\n✅	All eligible files processed!")

if __name__ == "__main__":
	# Date range to process is defined
	if len(sys.argv) == 2:
		main(sys.argv[1])
	else:
		main()
