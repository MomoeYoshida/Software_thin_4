function [ok]= process_raw_rtg(year, day, res, thin);

% Program to process RTG data (1/2 degree or 1/12 degree)

global file_info par_info return_flag
global yesterday

init_par_info;
init_file_info;

dir_input_ssts=file_info.dir_input_ssts;
dir_analysis=file_info.dir_analysis;
dir_ancillary=file_info.dir_ancillary;
name_sst_biases=file_info.name_sst_biases;
name_land_mask=file_info.name_land_mask;
spatial_resolution=par_info.spatial_resolution;
tenth_or_twentieth=par_info.tenth_or_twentieth;

% Get thresholds from init_par_info file to be used for SST check.
% These are used to set climate threshold used for processing, eg:
%
%     Threshold =  noaa17_day_c0_threshold_mult*sst_variability + noaa17_day_c0_threshold_constant

std_threshold=par_info.std_threshold;

abs_zero=par_info.abs_zero;

sst_analysis_min=par_info.sst_analysis_min;
rtg_fac         =par_info.rtg_fac  
sst_min=sst_analysis_min-2;

% Assign file and parameter information to variable names.
dir_rtg_lowres  = file_info.dir_rtg_lowres; 
dir_rtg_hires   = file_info.dir_rtg_hires;
dir_rtg_lowres  = file_info.dir_rtg_lowres;
dir_rtg_hires   = file_info.dir_rtg_hires;
dir_ms_read_grib = file_info.dir_ms_read_grib;
name_rtg_lowres = file_info.name_rtg_lowres;        
name_rtg_hires  = file_info.name_rtg_hires; 
    

sst=-1;
landmask=-1;

% add read_grib path
eval(['addpath ' dir_ms_read_grib]);

% Get the 0.1x0.1 degree land mask

message2(['*** Loading Landmask' dir_ancillary name_land_mask])
eval(['load ' dir_ancillary name_land_mask ' land_mask ']);
message2(['*** Loaded ' dir_ancillary name_land_mask]);
land=find(land_mask<1);

% Resampling factors for 1/2 or 1/12 degree resolution RTG

%rtg_fac=[5, 5./6.];

datalabel = 'rtg_';

mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];


if(res)
    
   gribfile=[dir_rtg_hires name_rtg_hires datestring];
   ydim=2160;
   xdim=4320;

else

   gribfile=[dir_rtg_lowres name_rtg_lowres datestring];
   ydim=360;
   xdim=720;

end

% Make sure it's there...

sstfiles=dir(gribfile);
nfiles=length(sstfiles);

message2(['*** Found ' num2str(nfiles) ' files for ' gribfile]);

% Warn user if no files found.

if(nfiles==0)
   message2(['*** Could not find ' gribfile '.'])
   message2(['*** No files found for RTG for '...
         num2str(year) ', day ' num2str(day) '. '])
   message2(['*** Check appropriate directory has been defined in init_file_info.'])
   ok=0;
   return
end

%nfiles=1;

% Set up geographical grids at 0.1deg spatial resolution to store SSTs
% and associated information. Each individual input file contributes a 
% maximum of one SST to every cell. Up to nmax values can be stored for one 
% day. 

nmax=1;
%gridcount=zeros(1800,3600);    % These are generated later...
allvals=NaN*ones(spatial_resolution);
%stdvals=zeros(1800,3600);
%dumparray=zeros(1800,3600);
bias=zeros(spatial_resolution);     % Always zero for RTG data...

% Get the data...

sst = get_rtg_grib(year, day, res);     % Converts from K to Celsius...

% Put on 0.1x0.1 degree grid...

sst=rebin(sst,rtg_fac(res+1),'linear');
sst(land)=NaN;

% Save RTG in Analysis directory for comparison...

message2(['*** Saving RTG file for ' num2str(year) ', day ' num2str(day)]);

eval(['save ' dir_analysis datalabel tenth_or_twentieth ...
       num2str_pad_zeros(year,4) '_' num2str_pad_zeros(day,3) ...
          ' sst']);


% Subsample if needed...

allvals(1:thin:end,1:thin:end)=sst(1:thin:end,1:thin:end);

% Update other required grids

gridcount=~isnan(allvals);      % Actually does exactly what we want...
stdvals=gridcount.*0.5;         % currently set 0.5 K accuracy for RTG...

sst=allvals;
      
% Where no quality control has been done output datafiles are prefixed with "raw_"

%     if(sst_check)
        check_label='';     % We don't check RTG but it doesn't matter...
%     else
%        check_label='raw_';
%     end

% Save data in "input_ssts" directory.

     eval(['save ' dir_input_ssts check_label  datalabel ...
            num2str_pad_zeros(year,4) '_' num2str_pad_zeros(day,3) ...
          ' sst gridcount ' ...
          ' stdvals bias'])

     
clear sst gridcount stdvals allvals
