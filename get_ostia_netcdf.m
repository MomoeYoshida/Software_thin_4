function [sst, land, ice] = get_ostia_netcdf(year, day, varargin);
global file_info par_info return_flag;

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

% Assign file and parameter information to variable names.
dir_ostia  = file_info.dir_ostia; 
name_ostia = file_info.name_ostia;        

abszero=273.15;
sst=-1;
landmask=-1;

disp(year)
disp(day)

mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];

netcdf_file=[dir_ostia datestring name_ostia];

if exist(netcdf_file, 'file') ~= 2   %If yesterdays Ostia doesn't exist
  disp(['Using older Ostia data'])   %Use older Ostia data
  if (day > 1)
		  mjd=date2mjd(year,day-1)
  else
		  mjd=date2mjd(year,365)
  end
		[year, dayinmonth, month]=mjd2date(mjd);
	
		datestring=[num2str(year) num2str_pad_zeros(month,2) ...
		num2str_pad_zeros(dayinmonth,2)];
		netcdf_file=[dir_ostia datestring name_ostia];
end

ydim=3600;	%  Hard-wired (could change this to read attributes from netCDF)
xdim=7200;

disp(['*** Opening ' netcdf_file])

ncid = netcdf.open(netcdf_file, 'NC_NOWRITE')

sst  = netcdf.getVar(ncid, 3);			%  Variable 3 is analysed_sst (actually in Celsius*100)
sf   = netcdf.getAtt(ncid, 3, 'scale_factor');	%  Should be 0.01

%  Convert to floating point and transpose

sst = single(sst);
sst = sst*sf;
%sst = flipud(sst');

% Get land & ice masks (in this case, the indices of sea ice & land)

mask = netcdf.getVar(ncid, 6);		%  Cumulative: 1=ocean, 2=land, 4=lake, 8=ice
%mask = flipud(mask');			%  Put it in correct orientation
ice  = find(mask==9);			%  ocean + ice = 9
temp = ones(size(sst));
temp(find(mask==1 | mask==9)) = 0;	%  Zero ocean + sea ice
land = find(temp>0);			%  For our purposes, "land" = everything but ocean & sea ice


%sst=sst-abszero;	%  Not needed as add_offset should be 273.15 already and we're not applying it

%sst=swap_array(sst);	%  ** Shouldn't be needed for OSTIA but check this **
