function [ok]= process_raw_mio_c(stream, year, day, ref_sst, sst_variability, sst_check);

% Program to process MSG data over the Indian Ocean

global file_info par_info return_flag blended_sst_home
global yesterday

init_par_info;
init_file_info;

dir_input_ssts=file_info.dir_input_ssts;
dir_analysis=file_info.dir_analysis;
name_sst_biases=file_info.name_sst_biases;

start_day_night=par_info.start_day_night;
end_day_night=par_info.end_day_night;

message2(['*** In process_raw_mio '])

% Get thresholds from init_par_info file to be used for SST check.
% These are used to set climate threshold used for processing, eg:
%
%     Threshold =  noaa17_day_c0_threshold_mult*sst_variability + noaa17_day_c0_threshold_constant

std_threshold=par_info.std_threshold;

spatial_resolution=par_info.spatial_resolution;

abs_zero=par_info.abs_zero;

sst_analysis_min=par_info.sst_analysis_min;
sst_min=sst_analysis_min-2;
daystr=get_datestring(year,day);

% Set initial status to 'ok'.

ok=1;

% Set up geographical grids at correct spatial resolution to store SSTs
% and associated information. Each individual input file contributes a 
% maximum of one SST to every cell. Up to nmax values can be stored for one 
% day. 

nmax=1;
gridcount=zeros(spatial_resolution);
allvals=NaN*ones(spatial_resolution);
stdvals=zeros(spatial_resolution);
dumparray=zeros(spatial_resolution);

% Name of bias file (derived from 'yesterday')

bias_file=[dir_analysis name_sst_biases yesterday];
full_bias_file=[dir_analysis name_sst_biases yesterday '.mat'];

% Since MEX routine always expects 10 parameters, initialize
% day & night bias variables in case they are not created below

bias_day=0.;
bias_night=0.;

% Load up data for required file types prior to extracting & binning

%
%  MSG-Indian-Ocean
%

geo_name = ['mio'];

for filetype=start_day_night:end_day_night    %  Day and/or night cases...
   
   switch filetype
      case 0
         messagelabel='Daytime';
         cmask=0;
         datalabel_day = [geo_name '_day_'];
         biaslabel=datalabel_day;
   
% Load up appropriate biases from yesterday's biases file.

         fid1=fopen(full_bias_file,'r');
  
         if(fid1>0)
            fclose(fid1);
            message2(['*** Loading bias file ' bias_file])
            eval(['load ' bias_file ' ' biaslabel 'bias '])
            eval(['bias_day=' biaslabel 'bias;'])
            message2(['*** Setting bias to ' biaslabel 'bias'])

         else    
            message2(['*** Bias file ' bias_file ' not found. Using bias =0;'])
            bias_day=0;
         end

      case 1
         messagelabel='Nighttime';
         cmask=0;
         datalabel_night= [geo_name '_night_'];
         biaslabel=datalabel_night;
         
% Load up appropriate biases from yesterday's biases file.

         fid1=fopen(full_bias_file,'r');
  
         if(fid1>0)
            fclose(fid1);
            message2(['*** Loading bias file ' bias_file])
            eval(['load ' bias_file ' ' biaslabel 'bias '])
            eval(['bias_night=' biaslabel 'bias;'])
            message2(['*** Setting bias to ' biaslabel 'bias'])

         else    
            message2(['*** Bias file ' bias_file ' not found. Using bias =0;'])
            bias_night=0;
         end

      otherwise

         message2('Undefined file type')
   end

end

message2(['*** Processing ' geo_name])


[run_ok day_there sst_day stdvals_day gridcount_day pixel_extent_day ...
 night_there sst_night stdvals_night gridcount_night pixel_extent_night] ...
						    = process_raw_geo_mex(geo_name, year, day,...
                                                      ref_sst,...
                                                      sst_variability,...
                                                      sst_check, bias_day,...
                                                      bias_night, stream, blended_sst_home);

% Where no quality control has been done output, datafiles are prefixed with "raw_"
% The same for day & night

if(sst_check)
   check_label='';
else
   check_label='raw_';
end

% "Dummy" output data to be used in case of no raw data files found

gridcount2=zeros(spatial_resolution);
sst2=NaN*ones(spatial_resolution);
stdvals2=zeros(spatial_resolution);
bias2=zeros(spatial_resolution);
pixel_extent2='(601:3000,2401:4800)'	%  MSG SST pixel extent

% Save data in "input_ssts" directory.

for filetype=start_day_night:end_day_night    %  Determined from user selection in init_par_info.m...
   
   switch filetype
      case 0

         sst_size=size(sst_day);	%  Get the size of the input SST array.  Output arrays are still returned 
					%  by ingester even though raw data files are absent.  However, size of
					%  SST array will be [1 1] rather than (e.g.) [3600 7200]
         if((sst_size(1)*sst_size(2))>1)
            sst          = sst_day;
            gridcount    = gridcount_day;
            stdvals      = stdvals_day;
            bias         = bias_day;
	    pixel_extent = pixel_extent_day;
	 else
            sst          = sst2;
            gridcount    = gridcount2;
            stdvals      = stdvals2;
            bias         = bias2;
	    pixel_extent = pixel_extent2;
	 end
  
         clear sst_day gridcount_day stdvals_day bias_day

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])

	 sst(gridcount<1) = NaN;
	 stdvals(gridcount<1) = NaN;

         eval(['save ' dir_input_ssts check_label  datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst stdvals gridcount pixel_extent bias'])

      case 1

         sst_size=size(sst_night);	%  Get the size of the input SST array.  Output arrays are still returned 
					%  by ingester even though raw data files are absent.  However, size of
					%  SST array will be [1 1] rather than (e.g.) [3600 7200]
         if((sst_size(1)*sst_size(2))>1)
            sst          = sst_night;
            gridcount    = gridcount_night;
            stdvals      = stdvals_night;
            bias         = bias_night;
	    pixel_extent = pixel_extent_night;
	 else
            sst          = sst2;
            gridcount    = gridcount2;
            stdvals      = stdvals2;
            bias         = bias2;
	    pixel_extent = pixel_extent2;
	 end
  
         clear sst_night gridcount_night stdvals_night bias_night

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])

	 sst(gridcount<1) = NaN;
	 stdvals(gridcount<1) = NaN;

         eval(['save ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst stdvals gridcount pixel_extent bias'])

      otherwise

         message2('Undefined file type')

   end
    
end

clear sst gridcount stdvals dumparray allvals sst2 gridcount2 stdvals2 bias2


