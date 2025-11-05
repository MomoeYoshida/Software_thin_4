function [day_sst, day_std, day_n, night_sst, night_std, night_n, pixel_extent]= ...
                                    get_op_sst(year,day,data_type);
				    
global file_info par_info return_flag

init_par_info;
init_file_info;

% Get name of GOES operational SST directory.

dir_input_ssts=file_info.dir_input_ssts;
spatial_resolution=par_info.spatial_resolution;
cells_per_degree=par_info.cells_per_degree;

start_day_night          = par_info.start_day_night;
end_day_night            = par_info.end_day_night;


eval(['addpath ' dir_input_ssts])

global_size=[spatial_resolution];
global_sst=NaN*ones(global_size);


% Get string for date in GOES format.

datestring=get_goes_datestring(year,day);

% Check type is appropriate GOES type. If not, warn user and return.

data_type=lower(data_type);
if(~strcmp(data_type,'goese') & ~strcmp(data_type,'goesw') & ...
   ~strcmp(data_type,'goesp') & ~strcmp(data_type, 'noaa16_c0') & ...
   ~strcmp(data_type,'noaa16_c1') & ~strcmp(data_type, 'noaa17_c0') & ...
   ~strcmp(data_type,'noaa18_c0') & ~strcmp(data_type, 'noaa18_c1') & ...
   ~strcmp(data_type,'noaa17_c1' ) & ~strcmp(data_type,'goes') );
    message2('*** WARNING. No data files found.')
    message2('*** Data Type must be goese, goesw, goesp, goes, noaa16_c0, noaa16_c1, noaa17_c0 or noaa17_c1')
    day_sst=0; night_sst=0; pixel_extent=0;
   return
end



cloud_type='';
cut=0;
gridcount=0;


day_sst=global_sst;
day_std=global_sst;
day_n=global_sst;
	
night_sst=global_sst;
night_std=global_sst;
night_n=global_sst;


for filetype=start_day_night:end_day_night    %  Day and/or night cases...

   switch filetype
      case 0
        eval(['load ' data_type '_day_' cloud_type datestring ])

        % Fix to remove unfilled goes p data
        if(cut)
          sst=sst(:,1:700);
          stdvals=stdvals(:,1:700);
          if(size(gridcount)>1)
            gridcount=gridcount(:,1:700);
          end
        end




        day_sst=sst;
        day_std=stdvals;
        day_n=gridcount;

        %eval(['day_sst' pixel_extent '=sst;'])
        %eval(['day_std' pixel_extent '=stdvals;'])
        %eval(['day_n' pixel_extent '=gridcount;'])


      case 1
        %eval(['load ' data_type '_night_' cloud_type datestring ' sst stdvals gridcount'])
        eval(['load ' data_type '_night_' cloud_type datestring ])

   
        % Fix to remove unfilled goes p data
        if(cut)
          sst=sst(:,1:700);
          stdvals=stdvals(:,1:700);
          if(size(gridcount)>1)
            gridcount=gridcount(:,1:700);
          end
        end

        night_sst=sst;
        night_std=stdvals;
        night_n=gridcount;

        %eval(['night_sst' pixel_extent '=sst;'])
        %eval(['night_std' pixel_extent '=stdvals;'])
        %eval(['night_n' pixel_extent '=gridcount;'])
	

      otherwise
         message2('Undefined file type')
   end

end 
