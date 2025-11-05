function init_par_info ;
%
% initialises locations for input satellite data, intermediate data files etc.
%
global par_info;
%
% Correct for diurnal warming?
%
par_info.correct_diurnal_warming = 0;

%
% Type of data to ingest for both POES and GEO data
par_info.noaa16_acspo_format = 'GHRSST';
par_info.noaa17_acspo_format = 'GHRSST';
par_info.noaa18_acspo_format = 'GHRSST';
par_info.noaa19_acspo_format = 'GHRSST';
par_info.metopa_acspo_format = 'GHRSST';
par_info.metopb_acspo_format = 'GHRSST';
par_info.viirs_acspo_format = 'GHRSST';
par_info.jpss_acspo_format = 'GHRSST';
par_info.geo_format = 'GHRSST';
par_info.amsr_format = 'GHRSST';

% N.B. As things stand, ACSPO GHRSST data are *not* GDS-compliant, since 
% only QL5 data are considered usable, while QL4 is "probably cloudy" and QL3 is "bad"

par_info.acspo_ghrsst_min_quality = 5;
par_info.geo_ghrsst_min_quality = 4;
par_info.amsr_ghrsst_min_quality = 5;

%
% GHRSST correction of required
%
par_info.noaa16_sses_bias = 0;
par_info.noaa16_use_sses_stdev = 0;
par_info.noaa16_sses_stdev = 0.4;

par_info.noaa17_sses_bias = 0;
par_info.noaa17_use_sses_stdev = 0;
par_info.noaa17_sses_stdev = 0.4;

par_info.noaa18_sses_bias = 0;
par_info.noaa18_use_sses_stdev = 0;
par_info.noaa18_sses_stdev = 0.4;

par_info.noaa19_sses_bias = 0;
par_info.noaa19_use_sses_stdev = 0;
par_info.noaa19_sses_stdev = 0.4;

par_info.metopa_sses_bias = 0;
par_info.metopa_use_sses_stdev = 0;
par_info.metopa_sses_stdev = 0.4;

par_info.metopb_sses_bias = 1;
par_info.metopb_use_sses_stdev = 0;
par_info.metopb_sses_stdev = 0.4;

par_info.viirs_sses_bias = 1;
par_info.viirs_use_sses_stdev = 0;
par_info.viirs_sses_stdev = 0.4;

par_info.jpss_sses_bias = 1;
par_info.jpss_use_sses_stdev = 0;
par_info.jpss_sses_stdev = 0.4;

par_info.goese_sses_bias = 0;
par_info.goese_use_sses_stdev = 0;
par_info.goese_sses_stdev = 0.4;

par_info.goesw_sses_bias = 0;
par_info.goesw_use_sses_stdev = 0;
par_info.goesw_sses_stdev = 0.4;

par_info.goesp_sses_bias = 0;
par_info.goesp_use_sses_stdev = 0;
par_info.goesp_sses_stdev = 0.4;

par_info.mtsat_sses_bias = 0;
par_info.mtsat_use_sses_stdev = 0;
par_info.mtsat_sses_stdev = 0.4;

par_info.msg_sses_bias = 0;
par_info.msg_use_sses_stdev = 0;
par_info.msg_sses_stdev = 0.4;

par_info.mio_sses_bias = 0;
par_info.mio_use_sses_stdev = 0;
par_info.mio_sses_stdev = 0.4;

par_info.amsr_sses_bias = 0;
par_info.amsr_use_sses_stdev = 0;
par_info.amsr_sses_stdev = 0.6;

%
par_info.start_day_night = 0;		% Night
%par_info.start_day_night = 1;
par_info.end_day_night = 1;		% Day

par_info.abs_zero = 273.15;                                       % absolute zero
par_info.bad_val = -999.;
par_info.max_obs_deviation = 3.0;
par_info.correlation_scaling=0.4;
par_info.correlation_min= 8.0;
par_info.correlation_max=32.0;
par_info.oi_corr_parm_001 = [8, 16, 32];
%par_info.oi_corr_parm_001 = [4];
par_info.oi_corr_parm_002 = [200];
par_info.oi_corr_parm_003 = [200];
par_info.oi_function_type_001 = 7;
par_info.oi_function_type_002 = 7;
par_info.oi_function_type_003 = 7;
par_info.sst_variability_scaling=0.5;
par_info.obs_variation_max=6.0;
par_info.sst_variability_min=0.50;
par_info.sst_variability_max=3.00;
par_info.sst_variability_weighting=[0.8,0.2];
par_info.sst_analysis_min=-2.0;
par_info.sst_analysis_max=40.0;			%  Update "cap" to 40 Celsius (was 35 deg C)
par_info.oi_function_type=5;
par_info.oi_density=1;
par_info.oi_nweight=0;
par_info.analysis_smoothing_factor=4;
par_info.error_smoothing_factor=5;
par_info.bias_smoothing_factor=23;
par_info.bias_weighting_factor=[0.4, 0.6];   % Relative weighting given to old and new bias
                                             % when updating bias for each dataset at each 
                                             % time step
par_info.min_geo_obs_per_cell=5;
par_info.min_avhrr_obs_per_cell=5;	     %  Also used for AMSR - always likely to be the case...
par_info.spatial_resolution=[3600,7200];
par_info.cells_per_degree=20;
par_info.rtg_fac=[10, 1.6666666666667];
par_info.ref_latmin = -90.;
par_info.ref_lonmin = -180.;

par_info.error_val_max=1;

par_info.tenth_or_twentieth='twentieth_';

par_info.clim_threshold_1=6. ;         	% Set climate threshold for 1st pass of data
par_info.clim_threshold_2=3.;		% Set climate threshold for 2nd pass of data
par_info.clim_threshold_var_factor=10.;	% Set factor by which SST daily variability 
                                      	% is multiplied.par_info.clim_threshold_1=6.          
					% Set climate threshold for 1st pass of data

% Set up default values for standard deviation for GOES data where there are less than 3 contributing measurements 
% for a grid point. These are derived by looking at standard deviation as a function of scale for data with small 
% numbers of pixels per grid point. GOES P is less noisy than GOES East and West.

par_info.default_goes_std_p=0.7;   % Default STD for GOESP
par_info.default_goes_std_e=0.5;   % Default STD for GOESE
par_info.default_goes_std_w=0.8;   % Default STD for GOESW


par_info.default_msg_std=0.8;    % Default STD for MSG
par_info.default_mio_std=0.8;    % Default STD for MSG-Indian-Ocean
par_info.default_mtsat_std=0.5;  % Default STD for MTSAT

par_info.default_amsr_std=0.6;  % Default STD for AMSR


par_info.amsr_thin_factor=2;  % Thinning factor for AMSR




% All raw SSTs are compared with the reference SST (usually yesterdays SST) with a check of 
% the form:
%    if(abs(sst-ref_sst)> threshold )  then reject SST.
% These threshold are defined as:
%     threshold= k1*sst_variability +k2
%                where sst_variability is a spatio-temporally varying measure of the daily 
%                      SST variability at a location, and k1 and k2 are constants which are
%                      defined for each data type.
%   
% For example, for GOES data:  
%     Threshold =  goes_threshold_mult*sst_variability + goes_threshold_constant
                                   

par_info.goes_threshold_mult                = 2; % These are used to set climate threshold used for 
par_info.goes_threshold_constant            = 1; % checking GOES data.

par_info.msg_threshold_mult                 = 2; % These are used to set climate threshold used for
par_info.msg_threshold_constant             = 1; % checking MSG data.

par_info.mio_threshold_mult                 = 2; % These are used to set climate threshold used for
par_info.mio_threshold_constant             = 1; % checking MSG-Indian-Ocean data.

par_info.mtsat_threshold_mult               = 2; % These are used to set climate threshold used for
par_info.mtsat_threshold_constant           = 1; % checking MTSAT data.

par_info.VIIRS_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.VIIRS_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.JPSS_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.JPSS_day_c0_threshold_constant   = 1.5; % checking JPSS day data with cloudmask=0.
 
par_info.noaa17_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.noaa17_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.METOPA_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.METOPA_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.

par_info.METOPB_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.METOPB_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.VIIRS_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.VIIRS_day_c1_threshold_constant   = 1; % checking NOAA17 day data with cloudmask=1.
 
par_info.noaa17_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.noaa17_day_c1_threshold_constant   = 1; % checking NOAA17 day data with cloudmask=1.
 
par_info.VIIRS_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.VIIRS_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.JPSS_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.JPSS_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.noaa17_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.noaa17_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.METOPA_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.METOPA_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.METOPB_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.METOPB_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.VIIRS_night_c1_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.VIIRS_night_c1_threshold_constant = 1; % checking NOAA17 night data with cloudmask=1.
 
par_info.noaa17_night_c1_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.noaa17_night_c1_threshold_constant = 1; % checking NOAA17 night data with cloudmask=1.
 
                                     
par_info.noaa16_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.noaa16_day_c0_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=0.
 
par_info.noaa16_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.noaa16_day_c1_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=1.
 
par_info.noaa16_night_c0_threshold_mult     = 1.5; % These are used to set climate threshold used for 
par_info.noaa16_night_c0_threshold_constant = 1; % checking NOAA16 night data with cloudmask=0.
 
par_info.noaa16_night_c1_threshold_mult     = 1.5; % These are used to set climate threshold used for 
par_info.noaa16_night_c1_threshold_constant = 1 ;% checking NOAA16 night data with cloudmask=1.
 
                                                                          
par_info.noaa18_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.noaa18_day_c0_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=0.
 
par_info.noaa18_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.noaa18_day_c1_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=1.
 
par_info.noaa18_night_c0_threshold_mult     = 3; % These are used to set climate threshold used for 
par_info.noaa18_night_c0_threshold_constant = 1; % checking NOAA16 night data with cloudmask=0.
 
par_info.noaa18_night_c1_threshold_mult     = 1.5; % These are used to set climate threshold used for 
par_info.noaa18_night_c1_threshold_constant = 1 ;% checking NOAA16 night data with cloudmask=1.
 

par_info.noaa19_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.noaa19_day_c0_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=0.
 
par_info.noaa19_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.noaa19_day_c1_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=1.
 
par_info.noaa19_night_c0_threshold_mult     = 3; % These are used to set climate threshold used for 
par_info.noaa19_night_c0_threshold_constant = 1; % checking NOAA16 night data with cloudmask=0.
 
par_info.noaa19_night_c1_threshold_mult     = 1.5; % These are used to set climate threshold used for 
par_info.noaa19_night_c1_threshold_constant = 1 ;% checking NOAA16 night data with cloudmask=1.
 
par_info.amsr_day_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.amsr_day_threshold_constant   = 1; % checking NOAA16 day data with cloudmask=0.
 
par_info.amsr_night_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.amsr_night_threshold_constant = 1 ;% checking NOAA16 night data with cloudmask=1.
 

par_info.VIIRS_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.VIIRS_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.JPSS_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.JPSS_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.noaa17_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.noaa17_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.METOPA_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.METOPA_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.METOPB_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.METOPB_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.VIIRS_day_c1_std_default          = 1.00;  % Default STD value when no. obs. =1
par_info.VIIRS_night_c1_std_default        = 1.00;  % Default STD value when no. obs. =1
par_info.noaa17_day_c1_std_default          = 1.00;  % Default STD value when no. obs. =1
par_info.noaa17_night_c1_std_default        = 1.00;  % Default STD value when no. obs. =1
par_info.noaa18_day_c0_std_default          = 0.40;  % Default STD value when no. obs. =1
par_info.noaa18_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.noaa18_day_c1_std_default          = 1.00;  % Default STD value when no. obs. =1
par_info.noaa18_night_c1_std_default        = 0.80;  % Default STD value when no. obs. =1
par_info.noaa19_day_c0_std_default          = 0.40;  % Default STD value when no. obs. =1
par_info.noaa19_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.noaa19_day_c1_std_default          = 1.00;  % Default STD value when no. obs. =1
par_info.noaa19_night_c1_std_default        = 0.80;  % Default STD value when no. obs. =1

par_info.std_threshold                      = 0.8;  % STD value above which checking for 
                                                    % discrepant SSTs is used.   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File parameters
% GOES E/W

par_info.goes_e_xsize = 3000;
par_info.goes_e_ysize = 2100;
par_info.goes_e_minlat = -45.;
par_info.goes_e_maxlat = 60.;
par_info.goes_e_minlon = -180.;
par_info.goes_e_maxlon = -30.;

par_info.goes_w_xsize = 3000;
par_info.goes_w_ysize = 2100;
par_info.goes_w_minlat = -45.;
par_info.goes_w_maxlat = 60.;
par_info.goes_w_minlon = -180.;
par_info.goes_w_maxlon = -30.;
par_info.goese          = 'GOESE (GOES-16)';
par_info.goesw          = 'GOESW (GOES-15)';

% GOES P

par_info.goes_p_xsize = 1600;
par_info.goes_p_ysize = 1800;
par_info.goes_p_minlat = -42.;
par_info.goes_p_maxlat = 42.;
par_info.goes_p_minlon = 110.;
par_info.goes_p_maxlon = 200.;

% MSG

par_info.msg_xsize = 2400;
par_info.msg_ysize = 2400;
par_info.msg_minlat = -60.;
par_info.msg_maxlat = 60.;
par_info.msg_minlon = -60.;
par_info.msg_maxlon = 60.;

% MTSAT

par_info.mtsat_xsize = 2000;
par_info.mtsat_ysize = 2100;
par_info.mtsat_minlat = -45.;
par_info.mtsat_maxlat = 60.;
par_info.mtsat_minlon = 80.;
par_info.mtsat_maxlon = 180.;
par_info.mtsat          = 'Himawari-8';

% MSG-Indian-Ocean

par_info.mio_xsize = 2400;
par_info.mio_ysize = 2400;
par_info.mio_minlat = -15.;
par_info.mio_maxlat = 105.;
par_info.mio_minlon = -60.;
par_info.mio_maxlon = 60.;

