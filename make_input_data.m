% This is the first section of make_op_sst, I separated this part because of
% the out of memory problem. H.G. 09/21/2007

function [ok]=make_input_data(year,day,stream,varargin);


global file_info par_info return_flag

return_flag=1;

init_par_info;
init_file_info;

% Create a logfile if so specified in init_file_info (ie if file_info.logfile_required is non-zero.)
% This logfile is used for informational messages.

create_logfile(year,day,stream);

% 

% Master program to generate SST Analysis for single time step.

% First, generate input data for all datasets as specified in init_files_info.m
message2(['*** In make input, stream' stream])

generate_oi_input_data(year,day,stream);

% Merge all GOES data into two files, a nighttime and daytime file, for each day. 

if (strcmpi(stream,'goes') || strcmpi(stream,'all'))
	if (length(varargin) >0)
   		direction=varargin{1}(1);
	else
   		direction=1;
	end
%	merge_goes(year,day,direction);  %RILEY
end

% Generate OI based on input datasets.

%generate_oi_sst(year,day);

% Update bias correction for each dataset.

%update_all_biases(year,day);


% Close logfile.

close_logfile;

% Clear memory.

clear all;


% Set ok status to 1 on successful completion.


ok=1;
