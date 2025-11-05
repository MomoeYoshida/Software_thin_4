function [ok]= process_raw_avhrr_acspo_c(stream, year, day, ref_sst, sst_variability, sst_check);

% Program to process AVHRR CLAVRX data,

global file_info par_info return_flag blended_sst_home
global yesterday

init_par_info;
init_file_info;

dir_input_ssts=file_info.dir_input_ssts;
dir_analysis=file_info.dir_analysis;
name_sst_biases=file_info.name_sst_biases;
noaa_name=file_info.noaa_name;
metop_name=file_info.metop_name;

start_day_night=par_info.start_day_night;
end_day_night=par_info.end_day_night;


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

% Set up geographical grids at 0.05deg spatial resolution to store SSTs
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

for filetype=start_day_night:end_day_night    %  Just the day & night cloudflag=0 cases...
   
   switch filetype
      case 0
         messagelabel='Daytime: cloud mask=0';
         cmask=0;
         datalabel_day = [noaa_name '_day_c0_'];
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
         messagelabel='Nighttime: cloud mask=0';
         cmask=0;
         datalabel_night= [noaa_name '_night_c0_'];
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

message2(['*** Processing ' noaa_name ': ' messagelabel])


% Close logfile so that mex-file can open it

message2(['in process_raw_avhrr_acspo_c.m about to call process_raw_avhrr_acspo_mex'])
close_logfile;

[run_ok day_there sst_day stdvals_day gridcount_day dumparray_day ...
 total_bad_day_clim total_bad_day_stdev night_there sst_night ...
 stdvals_night gridcount_night dumparray_night total_bad_night_clim ...
 total_bad_night_stdev] = process_raw_avhrr_acspo_mex(noaa_name, year, day,...
                                                      ref_sst,...
                                                      sst_variability,...
                                                      sst_check, bias_day,...
                                                      bias_night, stream, blended_sst_home);

% Reopen logfile [N.B. fopen() is set to append]

create_logfile(year, day, 'blend');

% Where no quality control has been done output, datafiles are prefixed with "raw_"
% The same for day & night

if(sst_check)
   check_label='';
else
   check_label='raw_';
end

% Save data in "input_ssts" directory.

for filetype=start_day_night:end_day_night    %  Just the day & night cloudflag=0 cases...
   
   switch filetype
      case 0

% Where no quality control has been done output datafiles are prefixed with "raw_"

         sst       = sst_day;
         gridcount = gridcount_day;
         stdvals   = stdvals_day;
         dumparray = dumparray_day;
         bias      = bias_day;
  
         total_bad_clim  = total_bad_day_clim;   
         total_bad_stdev = total_bad_day_stdev;   

         clear sst_day gridcount_day stdvals_day dumparray_day bias_day

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])

       %Riley: Andy's bias fix
       sst(gridcount < 1) = NaN;	
						 stdvals(gridcount < 1) = NaN;
       %End fix

         eval(['save ' dir_input_ssts check_label datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst gridcount ' ...
          ' stdvals dumparray total_bad* bias'])

      case 1

         sst       = sst_night;
         gridcount = gridcount_night;
         stdvals   = stdvals_night;   
         dumparray = dumparray_night;
         bias      = bias_night;
  
         total_bad_clim  = total_bad_night_clim;   
         total_bad_stdev = total_bad_night_stdev;   

         clear sst_night gridcount_night stdvals_night dumparray_night bias_night

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])
       %Riley: Andy's bias fix
       sst(gridcount < 1) = NaN;	
						 stdvals(gridcount < 1) = NaN;
       %End fix

         eval(['save ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst gridcount ' ...
          ' stdvals dumparray total_bad* bias'])

      otherwise

         message2('Undefined file type')

   end
     
end

%
%  Load up the MetOp data
%

% Load up data for required file types prior to extracting & binning

for filetype=start_day_night:end_day_night    %  Just the day & night cloudflag=0 cases...
   
   switch filetype
      case 0
         messagelabel='Daytime: cloud mask=0';
         cmask=0;
         datalabel_day = [metop_name '_day_c0_'];
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
         messagelabel='Nighttime: cloud mask=0';
         cmask=0;
         datalabel_night= [metop_name '_night_c0_'];
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

message2(['*** Processing ' metop_name ': ' messagelabel])


% Close logfile so that mex-file can open it

message2(['in process_raw_avhrr_acspo_c.m about to call process_raw_avhrr_acspo_mex'])
close_logfile;

[run_ok day_there sst_day stdvals_day gridcount_day dumparray_day ...
 total_bad_day_clim total_bad_day_stdev night_there sst_night ...
 stdvals_night gridcount_night dumparray_night total_bad_night_clim ...
 total_bad_night_stdev] = process_raw_avhrr_acspo_mex(metop_name, year, day,...
                                                      ref_sst,...
                                                      sst_variability,...
                                                      sst_check, bias_day,...
                                                      bias_night, stream, blended_sst_home);

% Reopen logfile [N.B. fopen() is set to append]

create_logfile(year, day, 'blend');

% Where no quality control has been done output, datafiles are prefixed with "raw_"
% The same for day & night

if(sst_check)
   check_label='';
else
   check_label='raw_';
end

% Save data in "input_ssts" directory.

for filetype=start_day_night:end_day_night    %  Just the day & night cloudflag=0 cases...
   
   switch filetype
      case 0

% Where no quality control has been done output datafiles are prefixed with "raw_"

         sst       = sst_day;
         gridcount = gridcount_day;
         stdvals   = stdvals_day;
         dumparray = dumparray_day;
         bias      = bias_day;
  
         total_bad_clim  = total_bad_day_clim;   
         total_bad_stdev = total_bad_day_stdev;   

         clear sst_day gridcount_day stdvals_day dumparray_day bias_day

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])
       %Riley: Andy's bias fix
       sst(gridcount < 1) = NaN;	
						 stdvals(gridcount < 1) = NaN;
       %End fix

         eval(['save ' dir_input_ssts check_label datalabel_day ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst gridcount ' ...
          ' stdvals dumparray total_bad* bias'])

      case 1

         sst       = sst_night;
         gridcount = gridcount_night;
         stdvals   = stdvals_night;   
         dumparray = dumparray_night;
         bias      = bias_night;
  
         total_bad_clim  = total_bad_night_clim;   
         total_bad_stdev = total_bad_night_stdev;   

         clear sst_night gridcount_night stdvals_night dumparray_night bias_night

	 message2(['*** Saving ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3)])
       %Riley: Andy's bias fix
       sst(gridcount < 1) = NaN;	
						 stdvals(gridcount < 1) = NaN;
       %End fix

         eval(['save ' dir_input_ssts check_label datalabel_night ...
            num2str_pad_zeros(year, 4) '_' num2str_pad_zeros(day,3) ...
          ' sst gridcount ' ...
          ' stdvals dumparray total_bad* bias'])

      otherwise

         message2('Undefined file type')

   end
     
end

clear sst gridcount stdvals dumparray allvals

