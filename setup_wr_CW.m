function [ok]=setup_wr_CW(year, day);


global file_info par_info return_flag

return_flag=1;

init_par_info;
init_file_info;

% Create a logfile if so specified in init_file_info (ie if file_info.logfile_required is non-zero.)
% This logfile is used for informational messages.

create_logfile(year, day, 'blend');
% 

% Check processing direction to ensure the correct reference SST is used.
% Normally this is set to one, and the reference day is the day previous
% to the one in question. However if direction is -1, the day chronologically
% afterwards is used. Other values may also be specified. For example, if 
% direction is set to 7, the reference biases from 7 days ago will be used.
% 
%if (length(varargin) >0)
%   direction=varargin{1}(1);
%else
   direction=1;
%end

% Master program to generate SST Analysis for single time step.

% First, generate input data for all datasets as specified in init_files_info.m

%generate_oi_input_data(year, day, stream);

% Merge all GOES data into two files, a nighttime and daytime file, for each day. 


%merge_goes(year, day, direction);

% res=resolution (0=1/2 deg, 1=1/12 deg)
% thin=thinning factor (1=everything, 2=every other sample & line, etc.)
%
% Doing this after the goes & avhrr gives the chance for the RTG data
% to have been processed...

%res=1;
%thin=3;

%process_raw_rtg(year, day, res, thin);

% Update bias correction for each dataset.

%update_all_biases(year, day, direction);

% Generate OI based on input datasets.

%generate_oi_sst(year, day, direction);

% Write coastwatch file

dir_coastwatch           = file_info.dir_coastwatch;
dir_analysis             = file_info.dir_analysis;
dir_ancillary           = file_info.dir_ancillary;

name_coastwatch_file     = file_info.name_coastwatch_file;
name_sst_analysis        = file_info.name_sst_analysis;
name_error_analysis      = file_info.name_error_analysis;
name_ice_mask            = file_info.name_ice_mask;
name_land_mask           = file_info.name_land_mask;

yearstring=num2str_pad_zeros(year,4);
daystring=num2str_pad_zeros(day,3);
date_string=get_datestring(year,day);
today=date_string;
day_before=get_datestring(year,day-direction);  % How was this supposed to work before, I have no idea...
yesterday=day_before;


bad_val=par_info.bad_val;
max_val=par_info.sst_analysis_max;
min_val=par_info.sst_analysis_min;


eval(['load ' dir_analysis file_info.name_sst_analysis today ' sst_analysis']);
message2(['*** Loading for Coastwatch ' dir_analysis name_sst_analysis today])

eval(['load ' dir_analysis file_info.name_error_analysis today]);
message2(['*** Loading for Coastwatch ' dir_analysis name_error_analysis today]);

eval(['load ' dir_analysis file_info.name_ice_mask today ' ice_mask']);
message2(['*** Loading ' dir_analysis name_ice_mask today]);

message2(['*** Loading Landmask'])
eval(['load ' dir_ancillary file_info.name_land_mask ' land_mask ']);
message2(['*** Loading ' dir_ancillary name_land_mask]);

processing_date=date;
five_or_eleven_km='5km_';
filename=[dir_coastwatch name_coastwatch_file five_or_eleven_km yearstring daystring '.hdf'];

message2(['*** Writing Coastwatch file ' filename])
 ok=write_coastwatch_5km(filename, year, day, sst_analysis, error_analysis, ...
                    land_mask, ice_mask, processing_date, bad_val, max_val, min_val );

% Close logfile.

close_logfile;

% Clear memory.

clear all;


% Set ok status to 1 on successful completion.


ok=1;
