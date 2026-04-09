function init_par_info ;
%
% Original Producer: Andy Harris
% Editor: Momoe Yoshida, 2025-
%
% initialises locations for input satellite data, intermediate data files etc.
%
global par_info;
%
% Correct for diurnal warming?
% In C, 1 is considered True and 0 is considered False.
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
par_info.metopc_acspo_format = 'GHRSST';
par_info.viirs_acspo_format = 'GHRSST';
par_info.jpss_acspo_format = 'GHRSST';
par_info.slstr_format = 'GHRSST';
par_info.geo_format = 'GHRSST';
par_info.amsr_format = 'GHRSST';
par_info.insitu_format = 'GHRSST';

% N.B. As things stand, ACSPO GHRSST data are *not* GDS-compliant, since 
% only QL5 data are considered usable, while QL4 is "probably cloudy" and QL3 is "bad"
% For SLSTR, only QL=5 is recommended (and especially since we are using it as the bias correction reference)
% Only dual-view algorithms are going to be used as reference for now.  Although D3 is better (less noisy), it's too restrictive for high latitudes.
% SLSTR algorithm type is 1 - 5 => N2, N3R, N3, D2, D3.  Windspeed limit only applies to daytime.  Sentinel-3 is morning orbit, so 5 m/s should be OK.

par_info.acspo_ghrsst_min_quality = 5;
par_info.geo_ghrsst_min_quality = 4;
par_info.amsr_ghrsst_min_quality = 5;
par_info.slstr_ghrsst_min_quality = 4;
par_info.slstr_ghrsst_min_algorithm = 4;
par_info.slstr_ghrsst_min_windspeed = 5.0;
par_info.use_hr_drifter = 1;
par_info.use_drifter = 1;
par_info.use_gtmba = 1;
par_info.use_moored = 1;
par_info.use_argo = 1;
par_info.insitu_ghrsst_min_quality = 5;

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

% Andy: 0/1??
par_info.metopc_sses_bias = 0; % Jun-2025
%par_info.metopc_sses_bias = 1; Mar-2025
par_info.metopc_use_sses_stdev = 0;
par_info.metopc_sses_stdev = 0.4;

par_info.viirs_sses_bias = 1;
par_info.viirs_use_sses_stdev = 0;
par_info.viirs_sses_stdev = 0.4;

% Andy: 0/1??
par_info.jpss_sses_bias = 0; % Jun-2025
%par_info.jpss_sses_bias = 1; Mar-2025
par_info.jpss_use_sses_stdev = 0;
par_info.jpss_sses_stdev = 0.4;

par_info.slstra_sses_bias = 1;
par_info.slstra_use_sses_stdev = 0;
par_info.slstra_sses_stdev = 0.4;

par_info.slstrb_sses_bias = 1;
par_info.slstrb_use_sses_stdev = 0;
par_info.slstrb_sses_stdev = 0.4;

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

% 0 -> Day, 1 -> Night??
par_info.start_day_night = 0;		% Night <-- really? not Day?? see process_raw_goes_c.m
%par_info.start_day_night = 1; % Nightonly -> cause error: BiasDay and
%ref_sst have incompatible sizes in process_raw_geo_mex.c -> TNT: check
%BiasDay
par_info.end_day_night = 1;		% Day <-- really? not Night??

par_info.abs_zero = 273.15;                                       % absolute zero
par_info.bad_val = -999.;
par_info.max_obs_deviation = 3.0;
par_info.correlation_scaling=0.4;
par_info.correlation_min= 8.0;
par_info.correlation_max=32.0;

% Andy: [8, 24, 48]??
%par_info.oi_corr_parm_001 = [8, 24, 48]; Jun-2025
par_info.oi_corr_parm_001 = [8, 16, 32]; % I believe this is the one currenty used to produce GPB NRT SST
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
par_info.bias_smoothing_factor=45;
par_info.bias_weighting_factor=[0.4, 0.6];   % Relative weighting given to old and new bias
                                             % when updating bias for each dataset at each 
                                             % time step

par_info.bias_scaling_factor=0.9;            % Scaling factor to damp down previous day's bias in absence of data (a.k.a. relaxation to zero)
par_info.default_bias_sd=0.7;                % S.D. for cases where only one/two full-resolution obs-ref pixel(s) lie(s) within a coarse-resolution bias grid cell
par_info.bias_gradient_max=5;		     % Maximum gradient permitted in bias correction field.  SST was set to 10, so bias should be less (probably <<5)
par_info.bias_variation_max=3.0;	     % Choose half of the "obs_variation_max" for now.  Once biases are stabilized, this value may be too tolerant...

par_info.bias_variability_min=0.25;             %  Half of SST variability (may be too high)
par_info.bias_variability_max=1.5;              %  As above...
par_info.bias_variability_weighting=[0.8,0.2];  %  Weighted 80:20 old:new 
par_info.bias_variability_scaling=0.5;          %  No idea if this is sensible.  Copied from SST variability scaling for now...
par_info.bias_analysis_min=-5.0;                %
par_info.bias_analysis_max=5.0;			%  +/- 3 degK seems about right.  5 K seems crazy, but...


par_info.min_geo_obs_per_cell=5;
par_info.min_avhrr_obs_per_cell=5;	     %  Also used for AMSR - always likely to be the case...
par_info.thinning = 0; % 0/1, OFF/ON, 1=enable random thinning
par_info.thinning_ratio = 0.5;  % keep 50% of L2P samples
par_info.seed_base = 1000; % If you want a different random realization, simply change (e.g. 2000, 3000)
par_info.spatial_resolution=[3600,7200];
par_info.spatial_resolution_bias=[720,1440];
par_info.cells_per_degree=20;
par_info.cells_per_degree_bias=4;
par_info.rtg_fac=[10, 1.6666666666667];
par_info.ref_latmin = -90.;
par_info.ref_lonmin = -180.;

par_info.error_val_max=1;
par_info.error_val_max_bias=0.5;        % Don't know if this seems reasonable...

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
 
par_info.slstra_day_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.slstra_day_threshold_constant   = 1.5; % checking SLSTRA day data with QL=5.
 
par_info.slstrb_day_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.slstrb_day_threshold_constant   = 1.5; % checking SLSTRB day data with QL=5.
 
par_info.noaa17_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.noaa17_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.METOPA_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.METOPA_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.

par_info.METOPB_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.METOPB_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.METOPC_day_c0_threshold_mult       = 2; % These are used to set climate threshold used for 
par_info.METOPC_day_c0_threshold_constant   = 1.5; % checking NOAA17 day data with cloudmask=0.
 
par_info.VIIRS_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.VIIRS_day_c1_threshold_constant   = 1; % checking NOAA17 day data with cloudmask=1.
 
par_info.noaa17_day_c1_threshold_mult       = 1.5; % These are used to set climate threshold used for 
par_info.noaa17_day_c1_threshold_constant   = 1; % checking NOAA17 day data with cloudmask=1.
 
par_info.VIIRS_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.VIIRS_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.JPSS_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.JPSS_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.slstra_night_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.slstra_night_threshold_constant = 1; % checking SLSTRA night data with QL=5.
 
par_info.slstrb_night_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.slstrb_night_threshold_constant = 1; % checking SLSTRB night data with QL=5.
 
par_info.noaa17_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.noaa17_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.METOPA_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.METOPA_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.METOPB_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.METOPB_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
par_info.METOPC_night_c0_threshold_mult     = 2; % These are used to set climate threshold used for 
par_info.METOPC_night_c0_threshold_constant = 1; % checking NOAA17 night data with cloudmask=0.
 
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
par_info.slstra_day_std_default         =  0.50;  % Default STD value when no. obs. =1
par_info.slstra_night_std_default        = 0.40;  % Default STD value when no. obs. =1
par_info.slstrb_day_std_default         =  0.50;  % Default STD value when no. obs. =1
par_info.slstrb_night_std_default        = 0.40;  % Default STD value when no. obs. =1
par_info.noaa17_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.noaa17_night_c0_std_default        = 0.50;  % Default STD value when no. obs. =1
par_info.METOPA_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.METOPA_night_c0_std_default        = 0.40;  % Default STD value when no. obs. =1
par_info.METOPB_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.METOPB_night_c0_std_default        = 0.40;  % Default STD value when no. obs. =1
par_info.METOPC_day_c0_std_default         =  0.40;  % Default STD value when no. obs. =1
par_info.METOPC_night_c0_std_default        = 0.40;  % Default STD value when no. obs. =1
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

% MSG-Indian-Ocean

par_info.mio_xsize = 2400;
par_info.mio_ysize = 2400;
par_info.mio_minlat = -15.;
par_info.mio_maxlat = 105.;
par_info.mio_minlon = -60.;
par_info.mio_maxlon = 60.;

