function [ok]= process_raw_ice(year, day, res);

% Program to process NCEP OMB ice data (1/2 degree or 1/12 degree)

global file_info par_info return_flag
global yesterday

init_par_info;
init_file_info;


dir_analysis=file_info.dir_analysis;
dir_ancillary=file_info.dir_ancillary;
name_land_mask=file_info.name_land_mask;

% Assign file and parameter information to variable names.
dir_ice_lowres  = file_info.dir_ice_lowres;
dir_ice_hires   = file_info.dir_ice_hires;
name_ice_lowres = file_info.name_ice_lowres;        
name_ice_hires  = file_info.name_ice_hires;       

ice=-1;
landmask=-1;

spatial_resolution = par_info.spatial_resolution;
ice_fac = par_info.rtg_fac;

% Get the 0.1x0.1 degree land mask

message2(['*** Loading Landmask' dir_ancillary name_land_mask])
eval(['load ' dir_ancillary name_land_mask ' land_mask ']);
message2(['*** Loaded ' dir_ancillary name_land_mask]);
land=find(land_mask<1);

% Resampling factors for 1/2 or 1/12 degree resolution sea ice mask

%ice_fac=[5, 5./6.];

datalabel = 'ice_mask_';

mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];


if(res)
    
   gribfile=[dir_ice_hires name_ice_hires datestring '.dat'];
   ydim=2160;
   xdim=4320;

else

   gribfile=[dir_ice_lowres name_ice_lowres datestring '.dat'];
   ydim=360;
   xdim=720;

end

% Make sure it's there...

icefiles=dir(gribfile);
nfiles=length(icefiles);

message2(['*** Found ' num2str(nfiles) ' files for ' gribfile]);

% Warn user if no files found.

if(nfiles==0)
   message2(['*** Could not find ' gribfile '.'])
   message2(['*** No files found for Ice for '...
         num2str(year) ', day ' num2str(day) '. '])
   message2(['*** Check appropriate directory has been defined in init_file_info.'])
   ok=0;
   return
end

% Get the data...

%icec = get_ice_grib(year, day, res);     %  Operational ice is GRiB2 (no Matlab reader yet)
icec = get_ice_dat(year, day, res);     %  "raw" ice conc is already extracted 
					%  from GRiB file before running Matlab, so
					%  can use wgrib or wgrib2 in external script...

% Put on 0.1x0.1 degree grid...

icec=rebin(icec,ice_fac(res+1),'linear');
icec(land)=NaN;
ice=find(icec>0.5);
ice_mask=zeros(spatial_resolution);
ice_mask(ice)=1.0;
ice_mask(land)=2.0;

% Save Ice in Analysis directory for comparison...

message2(['*** Saving Ice Mask for ' num2str(year) ', day ' num2str(day)]);

eval(['save ' dir_analysis datalabel ...
       num2str_pad_zeros(year,4) '_' num2str_pad_zeros(day,3) ...
          ' ice_mask']);
   
clear icec ice_mask ice land_mask land
