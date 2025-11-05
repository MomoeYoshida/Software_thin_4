function [ok]=merge_goes(year,day, varargin);

% Get information about file locations and names and parameters.

message2(['*** Merging GOES data for Day ' num2str(day) ' Year ' num2str(year)])

global file_info par_info return_flag
global yesterday

init_file_info;
init_par_info;

spatial_resolution=par_info.spatial_resolution;

% Use global file_info structure as defined by init_file_info.m to 
% determine information about directories and filename.

dir_analysis             = file_info.dir_analysis;
dir_input_ssts           = file_info.dir_input_ssts;
name_sst_biases          = file_info.name_sst_biases;

start_day_night=par_info.start_day_night;
end_day_night=par_info.end_day_night;

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

date=get_datestring(year,day);
%day_before=get_datestring(year,day-1);
day_before=get_datestring(year,day-direction);  % How was this supposed to work before, I have no idea...


% Load up bias file.

eval(['load  ' dir_analysis name_sst_biases day_before ])

% Get gridded input data for all day and night GOES data.

[goese_day_sst, goese_day_std, goese_day_n, ...
 goese_night_sst, goese_night_std, goese_night_n, pixel_extent]= ...
                                    get_op_sst(year,day,'goese');

[goesw_day_sst, goesw_day_std, goesw_day_n, ...
 goesw_night_sst, goesw_night_std, goesw_night_n, pixel_extent]= ...
                                    get_op_sst(year,day,'goesw');

%[goesp_day_sst, goesp_day_std, goesp_day_n, ...
% goesp_night_sst, goesp_night_std, goesp_night_n, pixel_extent]= ...
%                                    get_op_sst(year,day,'goesp');


clear title


for filetype=start_day_night:end_day_night    %  Day and/or night cases...

   switch filetype
      case 0
        goese_day_sst_bc    = goese_day_sst+goese_day_bias;
        goesw_day_sst_bc    = goesw_day_sst+goesw_day_bias;
        %goesp_day_sst_bc    = goesp_day_sst+goesp_day_bias;

        goes_day=NaN*ones(spatial_resolution);
        goes_day_std=NaN*ones(spatial_resolution);
        goes_day_gridcount=NaN*ones(spatial_resolution);

        ok=find(~isnan(goesw_day_sst_bc));
        goes_day(ok)=goesw_day_sst_bc(ok);
        goes_day_std(ok)=goesw_day_std(ok);
        goes_day_gridcount(ok)=goesw_day_n(ok);

        ok=find(~isnan(goese_day_sst_bc));
        goes_day(ok)=goese_day_sst_bc(ok);
        goes_day_std(ok)=goese_day_std(ok);
        goes_day_gridcount(ok)=goese_day_n(ok);


        %ok=find(~isnan(goesp_day_sst_bc));
        %goes_day(ok)=goesp_day_sst_bc(ok);
        %goes_day_std(ok)=goesp_day_std(ok);
        %goes_day_gridcount(ok)=goesp_day_n(ok);
	
        bias=0;
        sst=goes_day;
        stdvals=goes_day_std;
        gridcount=goes_day_gridcount;
        eval(['save ' dir_input_ssts 'goes_day_' date ' sst stdvals bias gridcount'])
	
      case 1
        goese_night_sst_bc  = goese_night_sst+goese_night_bias;
	goesw_night_sst_bc  = goesw_night_sst+goesw_night_bias;
	%goesp_night_sst_bc  = goesp_night_sst+goesp_night_bias;
	
	goes_night=NaN*ones(spatial_resolution);
	goes_night_std=NaN*ones(spatial_resolution);
	goes_night_gridcount=NaN*ones(spatial_resolution);

        ok=find(~isnan(goesw_night_sst_bc));
        goes_night(ok)=goesw_night_sst_bc(ok);
        goes_night_std(ok)=goesw_night_std(ok);
        goes_night_gridcount(ok)=goesw_night_n(ok);

        ok=find(~isnan(goese_night_sst_bc));
        goes_night(ok)=goese_night_sst_bc(ok);
        goes_night_std(ok)=goese_night_std(ok);
        goes_night_gridcount(ok)=goese_night_n(ok);

        %ok=find(~isnan(goesp_night_sst_bc));
        %goes_night(ok)=goesp_night_sst_bc(ok);
        %goes_night_std(ok)=goesp_night_std(ok);
        %goes_night_gridcount(ok)=goesp_night_n(ok);
      
        bias=0;
        sst=goes_night;
        stdvals=goes_night_std;
        gridcount=goes_night_gridcount;
        eval(['save ' dir_input_ssts 'goes_night_' date ' sst stdvals bias gridcount'])

      otherwise
         message2('Undefined file type')
   end

end 
