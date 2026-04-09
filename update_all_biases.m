function update_all_biases(year, day, varargin);

global file_info par_info return_flag
global yesterday

disp(['here'])
init_par_info;
init_file_info;

return_flag=1;

message2(['*** Updating bias corrections using data from Day ' num2str(day) ' Year ' num2str(year)])

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

% Determine string for date in yyyy_ddd format from input year and day of year,
% where yyyy is year, and ddd is day of year.
% For example, day 36 of year 2004 is specified with the string "2004_036".
% Also get string for previous day, as various datafiles from the previous day will
% be required.

today=get_datestring(year,day);
yesterday=get_datestring(year,day-direction);

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

% Use global file_info structure as defined by init_file_info.m to 
% determine information about directories and filename.

dir_analysis             = file_info.dir_analysis;
name_sst_biases          = file_info.name_sst_biases;
var_n_datasets		 = file_info.var_n_datasets;
spatial_resolution       = par_info.spatial_resolution;

% Grab all biases

eval(['load ' dir_analysis name_sst_biases yesterday ' *bias'])

ostia_bias=zeros(spatial_resolution);	%  Just in case...

% Update the ones in the list, skipping the first one, which should be the bias-free reference (e.g. OSTIA)

for i=2:var_n_datasets
   disp(var_n_datasets) %RILEY
   name_dataset=['name_dataset_' sprintf('%03d', i)];
   eval(['data_label=file_info.' name_dataset ';']);
   eval(['[' data_label 'bias]=update_biases(year, day, data_label, direction);'])
end

% Save all biases to today's file

eval(['save ' dir_analysis name_sst_biases today ' *bias']) % sst_biases_yyyy_jjj.mat: save all variables whose names end with bias


