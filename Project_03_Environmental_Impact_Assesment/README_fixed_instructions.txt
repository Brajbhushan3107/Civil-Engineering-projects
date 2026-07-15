
RRTS Assignment - FIXED VERSION (robust MATLAB script)

Files in this package:
- air_quality_rrts.xlsx
- noise_levels_rrts.xlsx
- traffic_change_rrts.xlsx
- rrts_plots_script_fixed.m  (MATLAB script - robust file detection + pattern matching)
- README_sources_and_methodology.txt (original)
- README_fixed_instructions.txt (this file)

What was fixed:
- The original script failed if the working directory on the user's machine differed from the script's assumed path.
- rrts_plots_script_fixed.m now attempts to locate the data files in reasonable default locations. If not found, it opens a folder selection dialog (GUI) so you can point to the folder containing the Excel files.
- The script also locates columns by searching variable-name patterns (e.g., 'pm2', 'pm10', 'no2', 'so2', 'co', 'day', 'night', 'before', 'after'), making it tolerant to minor column-name differences.

How to run:
1. Unzip the package to a folder on your machine.
2. Open MATLAB.
3. Either:
   a) Set MATLAB's Current Folder to the unzipped folder (the script will find the 'rrts_assignment' subfolder automatically), OR
   b) Open the script 'rrts_plots_script_fixed.m' in the MATLAB editor and press Run. If the script cannot find the Excel files automatically, it will prompt you to select the folder containing them.
4. After running, PNG plots will be saved next to the Excel files (file names ending with '_fixed.png').

If you still get an "Unable to find or open" error, run the script from the MATLAB Editor (so mfilename('fullpath') returns the script path) or use the GUI folder selector to point to the data folder.

