function [sst, sst_variability,ok]= init_files_OSTIA(year, day);

%
% year = yyyy
% day = ddd (julian day)
%

% 1. Initialisation.

global file_info par_info return_flag

global yesterday

init_file_info;
init_par_info;
 
abs_zero=273.15; % 0°C % Why define variable which is unused?
sst_analysis_min=par_info.sst_analysis_min;
sst_min=sst_analysis_min-2;

% Using OSTIA which is 1/20 degree (same as new POES-GOES)
%
% OSTIA comes with ice mask as well
%
% Unfortunately older versions of Matlab don't come with 
% netCDF reader

dir_analysis             = file_info.dir_analysis
dir_ancillary            = file_info.dir_ancillary;
dir_input_ssts           = file_info.dir_input_ssts;
dir_ms_overlap           = file_info.dir_ms_overlap;
dir_ms_smoother          = file_info.dir_ms_smoother;
dir_ms_statecorr         = file_info.dir_ms_statecorr;
dir_ms_executable        = file_info.dir_ms_executable;

name_sst_analysis        = file_info.name_sst_analysis;
name_error_analysis      = file_info.name_error_analysis;
name_sst_variability     = file_info.name_sst_variability;
name_ice_mask            = file_info.name_ice_mask;
name_correlation_map     = file_info.name_correlation_map;
name_land_mask           = file_info.name_land_mask;
name_oi_oceans_coupling  = file_info.name_oi_oceans_coupling;
name_oi_state_values     = file_info.name_oi_state_values;
name_oi_scales           = file_info.name_oi_scales;
correlation_scaling      = par_info.correlation_scaling;
correlation_min          = par_info.correlation_min;
correlation_max          = par_info.correlation_max;

n_datasets               = file_info.var_n_datasets;

% Assign OSTIA file and parameter information to variable names.
dir_ostia  = file_info.dir_ostia;
name_ostia = file_info.name_ostia;        

% Set initial status to 'ok'.
ok=1;

% Convert input year and day into format used in OSTIA filenames.

date=get_datestring(year,day);

% 2. Get the OSTIA data of that day / Read a NetCDF file.

[start_sst, land, ice]=get_ostia_netcdf(year, day);
start_sst(land)=NaN;

ice_mask=zeros(size(start_sst));
ice_mask(ice)=1;
ice_mask(land)=2;
ice_mask=double(ice_mask');

land_mask=zeros(size(start_sst));
land_mask(land)=1;

land_or_ice=find(ice_mask>0);


% 3. Get the OSTIA data of 10 days before that day / Read a NetCDF file.
% ...and for 10 days prior to estimate variability
[earlier_sst, land2, ice2]=get_ostia_netcdf(year, day-10);
earlier_sst(land)=NaN;

% 4. Smooth earlier_sst by a factor of 9. % why smooth_factor of 9?? and what is this used for??
sst=smooth_analysis(earlier_sst, 9);
sst=sst'; % transpose [7200x3600] > [3600x7200]

% 5. Calculate the SST variability / absolute SST difference between the SST field 10 days ago and that day.
sst_variability=0.1*abs(earlier_sst-start_sst);
% what's the purpose of 0.1* > for the following line: imagesc(sst_variability,[0,1]);??
% abs(): doesn't matter the direction(+ve/-ve) of change??
sst_variability(land)=NaN;
sst_variability=double(sst_variability');% transpose [7200x3600] > [3600x7200]

% 6. Initialise a baseline error estimate map?
error_analysis=zeros(size(earlier_sst))+0.2; % why +0.2??
error_analysis(land)=NaN;
error_analysis=double(error_analysis');

% 7. Plot sst, sst_variability, error_analysis, ice_mask.
figure(1);
imagesc(sst);
figure(2);
imagesc(sst_variability,[0,1]);
figure(3);
imagesc(error_analysis,[0,1]);
figure(4);
imagesc(ice_mask,[0,2]); % 0=ocean, 1=ice, 2=land


% 8. Compute a correlation map.
% Use smoothed OSTIA to derive correlation lengths, etc.

sst_analysis=sst; % why use smoothed OSTIA 10 days before instead of that day??

% 8-1. Compute the rate of change (spatial gradient) of the SST field in
% x (east-west) and y (north-south).
% sharp gradients: fronts/boundaries
% smooth: stable water masses
[gradx,grady]=gradient(sst_analysis);
grad=sqrt(gradx.*gradx+grady.*grady); % combine x and y into a single magnitude map
invert_gradient=1./grad; % smaller inverse = larger gradient > shorter correlation length
correlation_map=invert_gradient*correlation_scaling; % why correlation_scaling=0.4??
correlation_map(land_or_ice)=correlation_max; % why use mask of that day here not 10 days before??
correlation_map=min(correlation_map, correlation_max); % upper bound: 32.0
correlation_map=max(correlation_map, correlation_min); % lower bound: 8.0
correlation_map=double(correlation_map);

% May as well use most recent OSTIA as the starting analysis...

sst_analysis=double(start_sst'); % so we want to save OSTIA of that day, right??
% OSTIA 10 days before is used to calculate sst_variability and
% correlation_map, correct??


message2(['*** 	Saving init files for ' date])
eval(['save ' dir_analysis file_info.name_sst_analysis date ' sst_analysis ']); % of that day
eval(['save ' dir_analysis file_info.name_sst_variability date ' sst_variability ']); % that day vs 10-days-ago
eval(['save ' dir_analysis file_info.name_error_analysis date ' error_analysis ']); % constant
eval(['save ' dir_analysis file_info.name_correlation_map date ' correlation_map ']); % of 10-days-ago
eval(['save ' dir_analysis file_info.name_ice_mask date ' ice_mask ']); % of that day

