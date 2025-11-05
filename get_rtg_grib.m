function [sst] = get_rtg_grib(year, day, varargin);
global file_info par_info return_flag;

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

% Assign file and parameter information to variable names.
dir_rtg_lowres  = file_info.dir_rtg_lowres; 
dir_rtg_hires   = file_info.dir_rtg_hires;
dir_rtg_lowres  = file_info.dir_rtg_lowres;
dir_rtg_hires   = file_info.dir_rtg_hires;
name_rtg_lowres = file_info.name_rtg_lowres;        
name_rtg_hires  = file_info.name_rtg_hires;       

if (length(varargin) >0)
   hires=varargin{1}(1);
else
   hires=0;
end

 
abszero=273.15;
sst=-1;
landmask=-1;


mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];


if(hires)
   gribfile=[dir_rtg_hires name_rtg_hires datestring];
   land_mask_file= [dir_rtg_hires 'land_mask_4320_2160.dat'];
   ydim=2160;
   xdim=4320;

else

   gribfile=[dir_rtg_lowres name_rtg_lowres datestring];
%   land_mask_file= [dir_rtg_lowres 'ls.dat'];
   ydim=360;
   xdim=720;

end

disp(['*** Opening ' gribfile])

%%%  GRIB2 code for processing grib2 RTG files

fid=fopen(gribfile);
sst=fread(fid,[xdim,ydim],'float');
%sst=flipud(sst');
sst=sst';
sst=circshift(sst,[0,xdim/2]);
sst=sst-abszero;
return
