function [ice] = get_ice_dat(year, day, varargin);
global file_info par_info return_flag;

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

% Assign file and parameter information to variable names.
dir_ice_lowres  = file_info.dir_ice_lowres; 
dir_ice_hires   = file_info.dir_ice_hires;
name_ice_lowres = file_info.name_ice_lowres;        
name_ice_hires  = file_info.name_ice_hires;       

if (length(varargin) >0)
   hires=varargin{1}(1);
else
   hires=0;
end

 
ice=-1;
landmask=-1;


mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];


if(hires)
   datfile=[dir_ice_hires name_ice_hires datestring '.dat'];
   ydim=2160;
   xdim=4320;

else

   datfile=[dir_ice_lowres name_ice_lowres datestring '.dat'];
   ydim=360;
   xdim=720;

end

disp(['*** Opening ' datfile])

fid=fopen(datfile);

ice=fread(fid,[xdim,ydim],'float');

%ice=flipud(ice');

%ice=swap_array(ice);

ice=circshift(ice',[0,xdim/2]);
