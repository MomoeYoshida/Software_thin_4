function init_file_info ;
%
% Original Producer: Andy Harris
% Editor: Momoe Yoshida, 2025-Oct-21
%
% initialises locations for input satellite data, intermediate data files etc.
%
global file_info blended_sst_home
%

file_info.logfile_required    = 1;                % Set this to 1 if logfile is required, or 0 if not.
                                                  % Logfile will be named
file_info.name_logfile        = 'noaa_op_sst_';   % Name for logfile (date will be appended to this name,
                                                  % and file extension ('.log' will be used.)
                                                  % eg full filename would be  noaa_op_sst_2005_284.log
                                                  % Log file is written to dir_analysis directory.


% Change the path name according to your system settings.
%blended_sst_home = '/Users/momotalo/Documents/geo_polar_blended_sst/macOS_MacBookPro/blended_home'; % Local (MacBook Pro)
blended_sst_home = '/gpfs01/v2/Q9157/momoe/geo_polar_blended_sst/Linux_JCUHPC/blended_home'; % HPC

% Keep the sub-directory names as following (so that I don't have to modify
% this code.
%
% use mkdir -p "" to create directories

% End of Change


file_info.dir_metopa_sst     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopa_nav     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopb_sst     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopb_nav     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopc_sst     = [blended_sst_home '/Data/sst_metopc/'];
file_info.dir_metopc_nav     = [blended_sst_home '/Data/sst_metopc/'];
file_info.dir_noaa_16_sst   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_16_nav   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_17_sst   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_17_nav   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_18_sst   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_18_nav   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_19_sst   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_noaa_19_nav   = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_viirs_sst  = [blended_sst_home '/Data/sst_npp/'];
file_info.dir_viirs_nav  = [blended_sst_home '/Data/sst_npp/'];
%file_info.dir_jpss_sst  = [blended_sst_home '/Data/sst_noaa/'];
%file_info.dir_jpss_nav  = [blended_sst_home '/Data/sst_noaa/'];
file_info.dir_jpss_sst  = [blended_sst_home '/Data/sst_jpss/'];
file_info.dir_jpss_nav  = [blended_sst_home '/Data/sst_jpss/'];
file_info.dir_slstra_sst  = [blended_sst_home '/Data/slstr/'];
file_info.dir_slstra_nav  = [blended_sst_home '/Data/slstr/'];
file_info.dir_slstrb_sst  = [blended_sst_home '/Data/slstr/'];
file_info.dir_slstrb_nav  = [blended_sst_home '/Data/slstr/'];
file_info.dir_goes   = [blended_sst_home '/Data/goes/'];
file_info.dir_msg    = [blended_sst_home '/Data/msg/'];
file_info.dir_mio    = [blended_sst_home '/Data/mio/'];
file_info.dir_mtsat  = [blended_sst_home '/Data/mtsat/'];

file_info.dir_amsr     = [blended_sst_home '/Data/amsr/'];


file_info.dir_ms_read_grib  = [blended_sst_home '/MS/read_grib/'];
file_info.dir_ms_overlap    = [blended_sst_home '/MS/Overlap/'];
file_info.dir_ms_smoother   = [blended_sst_home '/MS/Smoother/'];
file_info.dir_ms_statecorr  = [blended_sst_home '/MS/StateCorr/'];
file_info.dir_ms_executable = [blended_sst_home '/MS/Newcode/'];


% looks like rtg files never be used
file_info.dir_rtg_lowres        = [blended_sst_home '/Data/Rtg/'];
file_info.dir_rtg_hires         = [blended_sst_home '/Data/Rtg_hires/'];
file_info.name_rtg_lowres        = 'rtg_sst_grb_0.5.';
file_info.name_rtg_hires         = 'rtg_sst_grb_hr_0.083.';

file_info.dir_input_ssts    = [blended_sst_home '/Input_ssts_thinning/'];
file_info.dir_analysis      = [blended_sst_home '/Analysis_thinning/'];
file_info.dir_ancillary     = [blended_sst_home '/Ancillary/'];
file_info.dir_coastwatch    = [blended_sst_home '/Coastwatch/'];
file_info.dir_GHRSST        = [blended_sst_home '/GHRSST/'];


file_info.name_sst_analysis       = 'sst_analysis_';
file_info.name_error_analysis     = 'error_analysis_';
file_info.name_sst_variability    = 'sst_variability_';
file_info.name_ice_mask           = 'ice_mask_';
file_info.name_correlation_map    = 'correlation_map_';
file_info.name_obs_correlation_map    = 'obs_correlation_map_';
% Two different variables below have the same name 'sst_biases_'.
file_info.name_biases             = 'sst_biases_';
file_info.name_sst_biases         = 'sst_biases_';
file_info.name_land_mask          = 'land_mask_twentieth';
file_info.name_oi_oceans_coupling = 'oi_oceans_coupling';
file_info.name_oi_state_values    = 'oi_state_values';
file_info.name_oi_scales          = 'oi_scales';
file_info.name_coastwatch_file    = 'sst_geo-polar-blended_night_';

file_info.name_oi_scales_bias          = 'oi_scales_bias';
file_info.name_oi_oceans_coupling_bias = 'oi_oceans_coupling_bias';
file_info.name_oi_state_values_bias    = 'oi_state_values_bias';

file_info.name_land_mask_bias     = 'land_mask_bias';

file_info.name_bias_analyses         = 'bias_analyses_';
file_info.name_bias_error_analyses   = 'bias_error_analyses_';
file_info.name_bias_variabilities    = 'bias_variabilities_';
file_info.name_bias_correlation_maps = 'bias_correlation_maps_';

% remove c1 data set, 2008/01/14
% add OSTIA data set as unbiased one, 2014/04/28
% separated GOES into E & W (no need for merge_goes() now)
% Note that 'noaa_name' and 'metop_name' are code for 'afternoon' and 'morning' satellites
% Also, all original NOAA satellites (16, 17, 18, 19) should be lower-case here
%file_info.var_n_datasets = 19;
%file_info.var_n_datasets = 10; % nighttime only, CoralTemp
%file_info.var_n_datasets = [1,2,3,4,5,6,7,8,10] % Momoe % e.g., [1,2,3,4,5,6,7,8,10] remove #009 mtsat_night % this type/shape change is dangerous because MEX is not robust to that, introducing a mismatch between MATLAB passes and what MEX assumes
% [P1]: never compute values inside this init_file_info.m!!
% Momoe ************************************************* 
file_info.dataset_ids = [1,2,3,4,5,6,7,8,10]; % DO NOT remote 1-ostia
file_info.var_n_datasets = 9;
%file_info.var_n_datasets = numel(file_info.dataset_ids); % "MATLAB init_file_info.m code cannot have implicit calculations in it." in ../C_code/init_file_info.c
% ANDY: The change here causes the segfault?
% Momoe *************************************************

file_info.var_n_datasets_start = 2; % skip first one for bias-correction

file_info.jpss_name = 'jpss';
file_info.noaa_name = 'viirs';
file_info.amsr_name = 'amsr2';
file_info.metop_name = 'METOPB';
file_info.metopc_name = 'METOPC';

file_info.name_dataset_001 = 'ostia_';
file_info.name_dataset_002 = 'viirs_night_c0_';
file_info.name_dataset_003 = 'METOPB_night_c0_';
file_info.name_dataset_004 = 'METOPC_night_c0_';
file_info.name_dataset_005 = 'goese_night_';
file_info.name_dataset_006 = 'goesw_night_';
file_info.name_dataset_007 = 'msg_night_';
file_info.name_dataset_008 = 'mio_night_';
file_info.name_dataset_009 = 'mtsat_night_';
file_info.name_dataset_010 = 'jpss_night_c0_';
file_info.name_dataset_011 = 'viirs_day_c0_';
file_info.name_dataset_012 = 'METOPB_day_c0_';
file_info.name_dataset_013 = 'METOPC_day_c0_';
file_info.name_dataset_014 = 'goese_day_';
file_info.name_dataset_015 = 'goesw_day_';
file_info.name_dataset_016 = 'msg_day_';
file_info.name_dataset_017 = 'mio_day_';
file_info.name_dataset_018 = 'mtsat_day_';
file_info.name_dataset_019 = 'jpss_day_c0_';
%file_info.name_dataset_018 = 'amsr2_night_';

file_info.n_datasets_bias = 4;

file_info.name_bias_dataset_001 = 'slstra_night_';
file_info.name_bias_dataset_002 = 'slstrb_night_';
file_info.name_bias_dataset_003 = 'slstra_day_';
file_info.name_bias_dataset_004 = 'slstrb_day_';

% the following lines are added for modified icemask
file_info.dir_ice_lowres        = [blended_sst_home '/Data/Ice/'];
file_info.dir_ice_hires         = [blended_sst_home '/Data/Ice/'];
file_info.name_ice_lowres        = 'seaice.oper.';
file_info.name_ice_hires         = 'seaice.oper.5min.';

file_info.dir_Diurnal  = [blended_sst_home '/Diurnal'];
%file_info.name_Diurnal = 'test_stokes_c_wg_5s_1.0_';
file_info.name_Diurnal = 'stokes_c_gfs+wave_';

% OSTIA data
file_info.dir_ostia         = [blended_sst_home '/Data/OSTIA/'];
% GHRSST Level 4 OSTIA Global Foundation Sea Surface Temperature Analysis (GDS version 2)
file_info.name_ostia        = '120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.0-fv02.0.nc';  % URL: https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-v2.0
%file_info.name_ostia        = '-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc';


