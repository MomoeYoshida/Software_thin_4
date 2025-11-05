function [sst, sst_variability,ok]= init_files_rtg_hres(year, day);

global file_info par_info return_flag

init_par_info;
init_file_info;

global yesterday
 
abs_zero=273.15
sst_analysis_min=par_info.sst_analysis_min;
sst_min=sst_analysis_min-2;
spatial_resolution=par_info.spatial_resolution;

% Use global file_info structure as defined by init_file_info.m to 
% determine information about directories and filename.

dir_analysis             = file_info.dir_analysis;
dir_ancillary             = file_info.dir_ancillary;
dir_input_ssts           = file_info.dir_input_ssts;
dir_ms_overlap           = file_info.dir_ms_overlap;
dir_ms_smoother          = file_info.dir_ms_smoother;
dir_ms_statecorr         = file_info.dir_ms_statecorr;
dir_ms_executable        = file_info.dir_ms_executable;
dir_ms_read_grib        = file_info.dir_ms_read_grib;

name_sst_analysis        = file_info.name_sst_analysis;
name_error_analysis      = file_info.name_error_analysis;
name_sst_variability     = file_info.name_sst_variability;
name_ice_mask            = file_info.name_ice_mask;
name_correlation_map     = file_info.name_correlation_map;
name_land_mask_tenth     = file_info.name_land_mask_tenth;
name_oi_oceans_coupling  = file_info.name_oi_oceans_coupling;
name_oi_state_values     = file_info.name_oi_state_values;
name_oi_scales           = file_info.name_oi_scales;
correlation_scaling=par_info.correlation_scaling;
correlation_min=par_info.correlation_min;
correlation_max=par_info.correlation_max;

n_datasets               = file_info.var_n_datasets;

eval(['addpath ' dir_ms_read_grib])

message2(['*** Loading Landmask'])
eval(['load ' dir_ancillary file_info.name_land_mask_tenth ' land_mask ']);
message2(['*** Loading ' dir_ancillary name_land_mask_tenth]);
land=find(land_mask<1);


% Set initial status to 'ok'.
ok=1;

% Convert input year and day into format used in CLAVR filenames.

date=get_datestring(year,day);

[start_sst]=get_rtg_grib(year,day,1);
start_sst=rebin(start_sst,5/6,'bilinear');
start_sst(land)=NaN;

[earlier_sst]=get_rtg_grib(year,day-10,1);
earlier_sst=rebin(earlier_sst,5/6,'bilinear');
earlier_sst(land)=NaN;

sst=smooth_analysis(earlier_sst, 9);

sst_variability=0.1*abs(earlier_sst-start_sst);

%sst_variability=rebin(sst_variability,5,'bilinear');
sst_variability(land)=NaN;

error_analysis=zeros(size(sst))+0.2;
error_analysis(land)=NaN;

ice_mask=zeros(size(sst));
%ice=find(abs(sst_variability<0.0008) | sst<-1.7 & (sst<0));


south_ice_mask=zeros(spatial_resolution);
north_ice_mask=zeros(spatial_resolution);
southern_ice=find(abs(sst<-1.7));
south_ice_mask(southern_ice)=1;

northern_ice=find(abs(sst<-1.4));
north_ice_mask(northern_ice)=1;
north_ice_mask(1750:1800,:)=1;


ice_mask(1:900,:)=south_ice_mask(1:900,:);
ice_mask(901:1800,:)=north_ice_mask(901:1800,:);

land_or_ice=find(ice_mask>0);

ice_mask(land)=2;
%figure(1)
%dimagesc(sst)
%figure(2)
%dimagesc(sst_variability,[0,1])
%figure(3)
%dimagesc(error_analysis,[0,1])
%figure(4)
%dimagesc(ice_mask,[0,2])

sst_analysis=sst;

[gradx,grady]=gradient(sst_analysis);
grad=sqrt(gradx.*gradx+grady.*grady);
invert_gradient=1./grad;
correlation_map=invert_gradient*correlation_scaling;
correlation_map(land_or_ice)=correlation_max;
correlation_map=min(correlation_map, correlation_max);
correlation_map=max(correlation_map, correlation_min);
%correlation_map=4*correlation_map;



%correlation_map_2005_020.mat    correlation_map(1800,3600)   4-16
%error_analysis_2005_020.mat     error_analysis(1800,3600)    0-3
%ice_mask_2005_020.mat           ice_mask(1800,3600) ice=1,land=2, sea=0
%sst_analysis_2005_020.mat       sst_analysis(1800,3600) 
%sst_variability_2005_020.mat    sst_variability(1800,3600) 0.02-0.9986


message2(['*** 	Saving init files for ' date])
eval(['save ' dir_analysis file_info.name_sst_analysis date ' *sst_analysis file_info ']);
eval(['save ' dir_analysis file_info.name_sst_variability date ' sst_variability ']);
eval(['save ' dir_analysis file_info.name_error_analysis date ' error_analysis ']);
eval(['save ' dir_analysis file_info.name_correlation_map date ' correlation_map ']);
eval(['save ' dir_analysis file_info.name_ice_mask date ' ice_mask ']);
