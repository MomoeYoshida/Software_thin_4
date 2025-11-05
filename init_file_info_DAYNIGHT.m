function init_file_info ;
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


% Change the following values according to your system settings
blended_sst_home = '/prod/GOES/5KM_BLENDED/DAY_NIGHT';

% end of change


file_info.dir_metopa_sst     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopa_nav     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopb_sst     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_metopb_nav     = [blended_sst_home '/Data/sst_metop/'];
file_info.dir_noaa_18_sst   = [blended_sst_home '/Data/sst_n18/'];
file_info.dir_noaa_18_nav   = [blended_sst_home '/Data/sst_n18/'];
file_info.dir_noaa_19_sst   = [blended_sst_home '/Data/sst_n19/'];
file_info.dir_noaa_19_nav   = [blended_sst_home '/Data/sst_n19/'];
file_info.dir_viirs_sst  = [blended_sst_home '/Data/sst_npp/'];
file_info.dir_viirs_nav  = [blended_sst_home '/Data/sst_npp/'];
file_info.dir_jpss_sst  = [blended_sst_home '/Data/sst_n20/'];
file_info.dir_jpss_nav  = [blended_sst_home '/Data/sst_n20/'];
file_info.dir_goes   = [blended_sst_home '/Data/goes_dn/'];
file_info.dir_msg    = [blended_sst_home '/Data/msg_dn/'];
file_info.dir_mio    = [blended_sst_home '/Data/mio_dn/'];
file_info.dir_mtsat  = [blended_sst_home '/Data/mtsat_dn/'];

file_info.dir_amsr     = [blended_sst_home '/Data/amsr/'];


file_info.dir_ms_read_grib  = [blended_sst_home '/MS/read_grib/'];
file_info.dir_ms_overlap    = [blended_sst_home '/MS/Overlap_MEX/'];
file_info.dir_ms_smoother   = [blended_sst_home '/MS/Smoother_MEX/'];
file_info.dir_ms_statecorr  = [blended_sst_home '/MS/StateCorr_MEX/'];
file_info.dir_ms_executable = [blended_sst_home '/MS/Newcode_MEX/'];



% looks like rtg files never be used
file_info.dir_rtg_lowres        = [blended_sst_home '/Data/Rtg/'];
file_info.dir_rtg_hires         = [blended_sst_home '/Data/Rtg_hires/'];
file_info.name_rtg_lowres       = 'rtg_sst_grb_0.5.grib2';
file_info.name_rtg_hires        = 'rtg_sst_grb_hr_0.083.grib2';

file_info.dir_input_ssts    = [blended_sst_home '/Input_ssts/'];
file_info.dir_analysis      = [blended_sst_home '/Analysis/'];
file_info.dir_ancillary     = [blended_sst_home '/Ancillary/'];
file_info.dir_coastwatch    = [blended_sst_home '/Coastwatch/'];
file_info.dir_GHRSST        = [blended_sst_home '/GHRSST/'];


file_info.name_sst_analysis       = 'sst_analysis_';
file_info.name_error_analysis     = 'error_analysis_';
file_info.name_sst_variability    = 'sst_variability_';
file_info.name_ice_mask           = 'ice_mask_';
file_info.name_correlation_map    = 'correlation_map_';
file_info.name_biases             = 'biases_';
file_info.name_land_mask          = 'land_mask_twentieth';
file_info.name_oi_oceans_coupling = 'oi_oceans_coupling';
file_info.name_oi_state_values    = 'oi_state_values';
file_info.name_oi_scales          = 'oi_scales';
file_info.name_coastwatch_file    = 'sst_geo-polar-blended_';
file_info.name_sst_biases         = 'sst_biases_';


% remove c1 data set, 2008/01/14
% add OSTIA data set as unbiased one, 2014/04/28
% separated GOES into E & W (no need for merge_goes() now)
% Note that 'noaa_name' and 'metop_name' are code for 'afternoon' and 'morning' satellites
% Also, all original NOAA satellites (16, 17, 18, 19) should be lower-case here
file_info.var_n_datasets = 17;

file_info.jpss_name = 'jpss';
file_info.noaa_name = 'viirs';
file_info.amsr_name = 'amsr2';
file_info.metop_name = 'METOPB';

file_info.name_dataset_001 = 'ostia_';
file_info.name_dataset_002 = 'viirs_night_c0_';
file_info.name_dataset_003 = 'viirs_day_c0_';
file_info.name_dataset_004 = 'METOPB_night_c0_';
file_info.name_dataset_005 = 'METOPB_day_c0_';
file_info.name_dataset_006 = 'goese_night_';
file_info.name_dataset_007 = 'goese_day_';
file_info.name_dataset_008 = 'goesw_night_';
file_info.name_dataset_009 = 'goesw_day_';
file_info.name_dataset_010 = 'msg_night_';
file_info.name_dataset_011 = 'msg_day_';
file_info.name_dataset_012 = 'mtsat_night_';
file_info.name_dataset_013 = 'mtsat_day_';
file_info.name_dataset_014 = 'mio_night_';
file_info.name_dataset_015 = 'mio_day_';
file_info.name_dataset_016 = 'jpss_night_c0_';
file_info.name_dataset_017 = 'jpss_day_c0_';

%file_info.name_dataset_015 = 'mtsat_day_';
%file_info.name_dataset_008 = 'amsr2_night_';

% the following lines are added for modified icemask
file_info.dir_ice_lowres        = [blended_sst_home '/Data/Ice/'];
file_info.dir_ice_hires         = [blended_sst_home '/Data/Ice/'];
file_info.name_ice_lowres        = 'seaice.oper.';
file_info.name_ice_hires         = 'seaice.oper.5min.';

file_info.dir_Diurnal  = [blended_sst_home '/Diurnal'];
%file_info.name_Diurnal = 'test_stokes_c_wg_5s_1.0_';
file_info.name_Diurnal = 'stokes_c_gfs+wave_';

% OSTIA data
file_info.dir_ostia         = [blended_sst_home '/Data/Ostia/'];
%file_info.name_ostia        = '-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.0-fv02.0.nc';
file_info.name_ostia        = '-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc';



