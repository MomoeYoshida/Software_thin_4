function [ok]=make_op_sst(year, day, stream, varargin);


global file_info par_info return_flag

return_flag=1;

init_par_info;
init_file_info;

% Create a logfile if so specified in init_file_info (ie if file_info.logfile_required is non-zero.)
% This logfile is used for informational messages.

create_logfile(year, day, 'blend'); % ../Analysis/noaa_op_sst_
% 

% Check processing direction to ensure the correct reference SST is used.
% Normally this is set to one, and the reference day is the day previous
% to the one in question. However if direction is -1, the day chronologically
% afterwards is used. Other values may also be specified. For example, if 
% direction is set to 7, the reference biases from 7 days ago will be used.
% 
if (length(varargin) >0)
   direction=varargin{1}(1);
else
   direction=1;
end

% Master program to generate SST Analysis for single time step.

% First, generate input data for all datasets as specified in init_files_info.m

generate_oi_input_data(year, day, stream);

% Update bias correction for each dataset.

update_all_biases(year, day, direction);

% Generate OI based on input datasets.

generate_oi_sst(year, day, direction);

% Close logfile.

close_logfile;

% Clear memory.

clear all;

% Set ok status to 1 on successful completion.

ok=1;
