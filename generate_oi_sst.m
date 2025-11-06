function [return_flag]=generate_oi_sst(year,day,varargin);
%
% Program to generate NOAA Operational Analysis from GOES
% and POES SST data.
%

% Add MS directory (and all its subfolders) to MATLAB path
addpath(genpath(fullfile('..', 'MS')));

message2(['*** Generating OI SST for Day ' num2str(day) ' Year ' num2str(year)])

global file_info par_info return_flag

return_flag=1;

init_par_info;
init_file_info;

start_day_night = par_info.start_day_night;
end_day_night = par_info.end_day_night;

max_val=par_info.sst_analysis_max;
min_val=par_info.sst_analysis_min;

bad_val=par_info.bad_val;
max_obs_deviation=par_info.max_obs_deviation;
correlation_min=par_info.correlation_min;
correlation_max=par_info.correlation_max;
correlation_scaling=par_info.correlation_scaling;

sst_variability_scaling=par_info.sst_variability_scaling;
sst_variability_min=par_info.sst_variability_min;
sst_variability_max=par_info.sst_variability_max;
sst_variability_weighting=par_info.sst_variability_weighting;
oi_corr_parm_001=par_info.oi_corr_parm_001;
oi_corr_parm_002=par_info.oi_corr_parm_002;
oi_corr_parm_003=par_info.oi_corr_parm_003;
oi_density=par_info.oi_density;
oi_nweight=par_info.oi_nweight;
oi_function_type=par_info.oi_function_type;
analysis_smoothing_factor=par_info.analysis_smoothing_factor;
error_smoothing_factor=par_info.error_smoothing_factor;
sst_analysis_min=par_info.sst_analysis_min;
sst_analysis_max=par_info.sst_analysis_max;
obs_variation_max=par_info.obs_variation_max;
error_val_max=par_info.error_val_max;
spatial_resolution=par_info.spatial_resolution;

% Use global file_info structure as defined by init_file_info.m to 
% determine information about directories and filename.

dir_analysis             = file_info.dir_analysis;
dir_input_ssts           = file_info.dir_input_ssts;
dir_ancillary           = file_info.dir_ancillary;
dir_coastwatch           = file_info.dir_coastwatch;

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
name_coastwatch_file     = file_info.name_coastwatch_file;

n_datasets               = file_info.var_n_datasets;


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

date_string=get_datestring(year,day);
today=date_string;
day_before=get_datestring(year,day-direction);  % How was this supposed to work before, I have no idea...

yearstring=num2str_pad_zeros(year,4);
daystring=num2str_pad_zeros(day,3);

yesterday=day_before;


message2(['*** DEBUG001 '])
% Load up required data files from previous day, informing user as
% files are loaded.

message2(['*** Loading up data from previous day: ' yesterday])

eval(['load ' dir_analysis file_info.name_sst_analysis yesterday ' sst_analysis']);
message2(['*** Loading ' dir_analysis name_sst_analysis yesterday])

eval(['load ' dir_analysis file_info.name_sst_variability yesterday ' sst_variability']);
message2(['*** Loading ' dir_analysis name_sst_variability yesterday]);

eval(['load ' dir_analysis file_info.name_correlation_map yesterday ' correlation_map']);
message2(['*** Loading ' dir_analysis name_correlation_map yesterday ]);

eval(['load ' dir_analysis file_info.name_ice_mask today ' ice_mask']);
message2(['*** Loading ' dir_analysis name_ice_mask today]);

message2(['*** Loading Landmask'])
eval(['load ' dir_ancillary file_info.name_land_mask ' land_mask ']);
message2(['*** Loading ' dir_ancillary name_land_mask]);


message2(['*** DEBUG002 '])
% Use ice and land masks to get vectors for ice and land positions.

land=find(land_mask==0);
ice=find(ice_mask==1);
land_or_ice=find(ice_mask>0);


% Modify daily SST variability for use in OI. 
% The mean absolute daily variation is stored and a scaled and constrained
% version is used by the OI to determine how much variability is 
% characteristic of tis location. However, this does NOT constrain the 
% estimated anomaly to be less than this value. 
%
% sst_variability_scaling = scaling factor: Typically 0.5.
% sst_variability_min    = minimum value allowed. 
% sst_variability_max    = maximum value allowed.

sst_variability=sst_variability_scaling*sst_variability;
sst_variability=min(sst_variability, sst_variability_max);
sst_variability=max(sst_variability, sst_variability_min);


% Load observational data

message2(['*** Loading Observational SSTs'])
message2(['*** DEBUG003 '])

obs_list='';
cov_list='';

full_obs=zeros(spatial_resolution);

for i=1:n_datasets
   
   data_string=num2str_pad_zeros(i,3);

   message2(['*** DEBUG004 '])
   
% Load up observational data.
   obs_file=['file_info.name_dataset_' data_string];
   eval(['obs_file=' obs_file ';'])
   
   full_obs_filename=[ dir_input_ssts obs_file date_string '.mat'];

% Check observational data are present. If not, insert empty dataset.

   sst=0.	%  Initialize SST 'array' to a scalar containing zero for testing (see below)

   fid=fopen(full_obs_filename);
   if(fid>0)   
      fclose(fid);
      eval(['load ' dir_input_ssts obs_file date_string ' sst stdvals gridcount bias']);
      message2(['*** Loading ' dir_input_ssts obs_file date_string]);
   end

   sst_size=size(sst);		%  Get the size of the input SST array.  Input file may still be created 
				%  by ingester even though raw data files are absent.  However, size of
				%  SST array will be [1 1] rather than (e.g.) [3600 7200]

   if(sst_size(1)*sst_size(2)==1)
      message2(['*** ' dir_input_ssts obs_file date_string ' not found; inserting empty dataset.'])
      sst=NaN*ones(spatial_resolution);
      stdvals=zeros(spatial_resolution);
      bias=zeros(spatial_resolution);
      eval(['save ' full_obs_filename ' sst stdvals bias']);
   end
   
% Set minimum value for standard deviation.

   too_low=find(stdvals<0.15);
   stdvals(too_low)=0.15;
   clear too_low
   if(0)
      only_one=find(gridcount==1);
      only_two=find(gridcount==2);
      stdvals(only_one)=0.5;
      stdvals(only_two)=0.4;
      clear only_one only_two
   end
   clear gridcount only_one only_two
   %pack         % old command that is now deprecated
   
   obs=sst+bias-sst_analysis;

   too_big=find(abs(obs)>max_obs_deviation);
   obs(too_big)=NaN;
   obs(land)=NaN;
   cov=stdvals.*stdvals;
   
   bad=find(isnan(obs));
   obs(bad)=bad_val;
   cov(bad)=bad_val;
   bad=find(stdvals==0);
   obs(bad)=bad_val;
   cov(bad)=bad_val;

      
   eval(['obs_' data_string '=obs;'])
   eval(['cov_' data_string '=cov;'])
   
   obs_list=[obs_list 'obs_' data_string ','];
   cov_list=[cov_list 'cov_' data_string ','];
 
   ok=find(obs>bad_val);
   full_obs(ok)=1;
                  message2(['*** DEBUG007'])
end
   message2(['*** DEBUG019'])

clear cov bias obs sst stdvals global_sst global_stdvals 

% Determine location of MultiScale (MS) estimation software.


% Now include these directories in the search path.
% User is advised which directories will be used.

message2(['*** Adding path to ' dir_ms_overlap])
eval(['addpath ' dir_ms_overlap])

message2(['*** Adding path to ' dir_ms_smoother])
eval(['addpath ' dir_ms_smoother])

message2(['*** Adding path to ' dir_ms_statecorr])
eval(['addpath ' dir_ms_statecorr])

message2(['*** Adding path to ' dir_ms_executable])
eval(['addpath ' dir_ms_executable])

   message2(['*** DEBUG020'])

% Read in other parameters used by OI.
% User is informed of files being loaded.

message2(['*** Loading ' dir_ancillary name_oi_oceans_coupling ]);
eval(['load ' dir_ancillary name_oi_oceans_coupling ]);
message2(['*** Loading ' dir_ancillary name_oi_state_values ]);
eval(['load ' dir_ancillary name_oi_state_values ]);
message2(['*** Loading ' dir_ancillary name_oi_scales ]);
eval(['load ' dir_ancillary name_oi_scales ]);
     
   message2(['*** DEBUG021'])


% Calculate estimates

n_fields = [1 2 2 1]; 
measurement_model = ones(n_datasets,1);
 
oi_scales=scales;

   message2(['*** DEBUG022'])

for i=1:length(oi_corr_parm_001)

   message2(['*** DEBUG030'])
   istring=num2str_pad_zeros(i,3);
   comstring=['[anom,est_error] = mult_groupb_new( oi_scales, oi_density, n_fields,' ...
                 'oi_function_type, ss1, oi_corr_parm_001(i), sst_variability, oi_nweight,' ...
                 'measurement_model, ' obs_list  cov_list ' land_mask, oi_oceans_coupling, [1 ]);']                             

   message2(['*** DEBUG031'])
   eval(comstring)
   message2(['*** DEBUG032'])
   



   anom=remove_overlap(anom, oi_scales);
  
   est_error=remove_overlap(est_error, oi_scales);
 
   vbad_anom=find((abs(anom)> obs_variation_max) & (land_mask>0) & (anom~=bad_val));
   vbad_error=find((est_error<0) & (land_mask>0) & (est_error~=bad_val));

     
   message2(['*** DEBUG034'])
  
   %corr_length=oi_corr_parm_001(i); not used anywhere else
 
% Constrain analysis by dumping result if estimated anomaly is greater than user-specified value.

   if(length(vbad_anom)>0)
      anom(vbad_anom)=0;
      est_error(vbad_anom)=3;
   end
   message2(['*** DEBUG035'])
   
   anom(land)=NaN;
   est_error(land)=NaN;

   [fx,fy]=gradient(anom);
   extreme=find(abs(fx)>10 | abs(fy)>10);
   if(length(extreme)>0)
      anom(extreme)=0.0;
      est_error(extreme)=3.;
   end
   clear fx fy extreme

   message2(['*** DEBUG038'])
   eval(['anom_' istring '=anom;'])
   eval(['error_' istring '=est_error;']) 
   clear anom est_error
 
   message2(['*** DEBUG039'])

end

message2(['*** DEBUG040'])


% Interpolate according to appropriate correlation map.

init_sst_analysis=sst_analysis;

message2(['*** DEBUG041'])

obs_correlation_map=get_cmap(full_obs,8,32);
clear full_obs
correlation_map=min(correlation_map,32);
correlation_map=max(8,correlation_map);

message2(['*** DEBUG042'])

% SST Analysis is modified using correlation map of SST variability
% modified by data distribution.
% Error Analysis correlation map is based only on underlying SST variability.

[anom_analysis, error_analysis]=corr_interp( obs_correlation_map, ...
                                     oi_corr_parm_001(1), anom_001, error_001, ...
                                     oi_corr_parm_001(2), anom_002, error_002, ...
                                     oi_corr_parm_001(3), anom_003, error_003); 

[anom_analysis_1, error_analysis]=corr_interp( correlation_map, ...
                                     oi_corr_parm_001(1), anom_001, error_001, ...
                                     oi_corr_parm_001(2), anom_002, error_002, ...
                                     oi_corr_parm_001(3), anom_003, error_003); 

message2(['*** DEBUG043'])

% Smooth analysis using smoothing factors set in init_par_info.

smooth_error_analysis=smooth_analysis(error_analysis,error_smoothing_factor);

good=find(~isnan(anom_analysis) & ~isnan(error_analysis));
unsmoothed_sst_analysis=0*init_sst_analysis;
unsmoothed_sst_analysis(good)=anom_analysis(good)+init_sst_analysis(good);
unsmoothed_sst_analysis(land)=bad_val;
error_analysis(land)=bad_val;

message2(['*** DEBUG044'])

sst_analysis=smooth_analysis(unsmoothed_sst_analysis,analysis_smoothing_factor);
good=find(~isnan(sst_analysis) & ~isnan(smooth_error_analysis));

% Constrain temperature of SST Analysis to user-specified range,
% typically -1.8 - 35.0 deg C. 
% val_min_sst_analysis & val_max_sst_analysis can be changed
% in init_par_info.m

bad=find(sst_analysis==bad_val | isnan(sst_analysis));
sst_analysis=min(sst_analysis, sst_analysis_max);
sst_analysis=max(sst_analysis, sst_analysis_min);
sst_analysis(bad)=bad_val;


% Set negative error values to bad value.

smooth_error_analysis(find(smooth_error_analysis<0))=error_val_max;
smooth_error_analysis=sqrt(smooth_error_analysis);
smooth_error_analysis(isnan(smooth_error_analysis))=bad_val;

message2(['*** DEBUG050'])

error_analysis=smooth_error_analysis;

% Modify SST Variability.

sst_variability(good)=sst_variability_weighting(1)*sst_variability(good) + ...
                      sst_variability_weighting(2)*abs(anom_analysis(good))+ ...
                      sqrt(error_analysis(good));

% Modify correlation map if required.

mod_correlation_map=0;
if(mod_correlation_map)
   [gradx,grady]=gradient(sst_analysis);
   grad=sqrt(gradx.*gradx+grady.*grady);
   invert_gradient=1./grad;
   correlation_map=invert_gradient*correlation_scaling; 
   correlation_map(land)=correlation_max;
   correlation_map=min(correlation_map, correlation_max);
   correlation_map=max(correlation_map, correlation_min);
   correlation_map=smooth_fill(correlation_map,land_mask,7);
   correlation_map=min(correlation_map, correlation_max);
   correlation_map=max(correlation_map, correlation_min);
end

message2(['*** DEBUG050'])
% Update and save SST Analysis

message2(['*** Writing results to ' dir_analysis])

eval(['save ' dir_analysis name_sst_analysis date_string ' *sst_analysis file_info']);
eval(['save ' dir_analysis name_error_analysis date_string ' error_analysis']);
eval(['save ' dir_analysis name_sst_variability date_string ' sst_variability']);
eval(['save ' dir_analysis name_correlation_map date_string ' correlation_map' ]);

message2(['*** DEBUG060'])

% Write coastwatch file

processing_date=date;
five_or_eleven_km='5km_';
filename=[dir_coastwatch name_coastwatch_file five_or_eleven_km yearstring daystring '.hdf'];

message2(['*** Writing Coastwatch file ' filename])
% ok=write_coastwatch_5km(filename, year, day, sst_analysis, error_analysis, ...
%                    land_mask, ice_mask, processing_date, bad_val, max_val, min_val );
		    
message2(['*** DEBUG070'])

% Write GHRSST L4 GSD 2.0 netCDF and metadata files
%%% Note: Landmask and ice mask loaded within write_ghrsst_gds2

if (start_day_night == 0) & (end_day_night == 1)
  message2(['*** Writing GHRSST L4 DAY/NIGHT files for day and year' num2str(day), num2str(year) ])
  ok=write_ghrsst_gds2_day_night(year, day, sst_analysis, error_analysis);
elseif (start_day_night == 1) & (end_day_night == 1)
  message2(['*** Writing GHRSST L4 NIGHT ONLY files for day and year' num2str(day), num2str(year) ])
  ok=write_ghrsst_gds2_night_only(year, day, sst_analysis, error_analysis);
end

return_flag=1;
