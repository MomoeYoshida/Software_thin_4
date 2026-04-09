#!/usr/bin/env python3
import datetime
import sys
from textwrap import dedent

def date_to_julian(date):
	"""Return year and Julian day (1–365/366)."""
	year = date.year
	julian = date.timetuple().tm_yday
	return year, julian

def generate_pbs(start_date, end_date):
	start = datetime.datetime.strptime(start_date, "%Y%m%d").date()
	end = datetime.datetime.strptime(end_date, "%Y%m%d").date()

	start_year, start_julian = date_to_julian(start)
	end_year, end_julian = date_to_julian(end)

	total_days = (end - start).days + 1

	pbs_script = dedent(f"""\
	#!/bin/bash
	#PBS -j oe
	#PBS -m ae
	#PBS -M momoe.yoshida@my.jcu.edu.au
	#PBS -N generate_oi_input_data_array
	#PBS -l select=1:ncpus=1:mem=64gb
	#PBS -l walltime=04:00:00
	#PBS -q short
	#PBS -J 1-{total_days}
	#PBS -o /home/heronlab/momoe/geo_polar_blended_sst/Linux_JCUHPC/blended_home/Logs/generate_oi_input_data_${{PBS_ARRAY_INDEX}}.log

	cd $PBS_O_WORKDIR
	module load matlab/2024a

	# --- DATE RANGE DEFINED BY PYTHON SCRIPT ---
	start_year={start_year}
	end_year={end_year}
	start_julian={start_julian}
	end_julian={end_julian}
	start_date="{start_date}"
	end_date="{end_date}"
	total_days={total_days}

	index=${{PBS_ARRAY_INDEX}}

	read YEAR DAY YYEAR YDAY <<< $(python3 - <<'EOF'
import datetime, os
start = datetime.datetime.strptime(os.environ["start_date"], "%Y%m%d").date()
offset = int(os.environ["index"]) - 1
current = start + datetime.timedelta(days=offset)
yesterday = current - datetime.timedelta(days=1)
print(f"{{current.year}} {{current.timetuple().tm_yday:03d}} {{yesterday.year}} {{yesterday.timetuple().tm_yday:03d}}")
EOF
)

	echo "🚀 Starting job for Year=${{YEAR}}, Day=${{DAY}} (yesterday: ${{YYEAR}},${{YDAY}})"
	date

	matlab -nodisplay -nosplash -r "try, \
		init_files_OSTIA(${{YYEAR}},${{YDAY}}); \
		init_all_biases(${{YYEAR}},${{YDAY}}); \
		generate_oi_input_data(${{YEAR}},${{DAY}},'mio'); \
	catch ME, disp(getReport(ME)); exit(1); end; exit"

	echo "✅ Finished Year=${{YEAR}}, Day=${{DAY}} at $(date)"
	""")

	return pbs_script


def main():
	if len(sys.argv) == 3:
		start_date, end_date = sys.argv[1], sys.argv[2]
		script = generate_pbs(start_date, end_date)

		# Dynamic filename with date range
		filename = f"generate_oi_input_data_array_{start_date}_{end_date}.pbs"

		with open(filename, "w") as f:
			f.write(script)

		print(f"✅ PBS script written to {filename}")
		print(f"Range: {start_date} → {end_date}")
		print(f"Submit using:")
		print(f"  qsub {filename}")
	else:
		print("Usage: python3 create_pbs_array_generate_oi_input_data.py START_DATE END_DATE")
		print("Example: python3 create_pbs_array_generate_oi_input_data.py 20241211 20250430")


if __name__ == "__main__":
	main()
