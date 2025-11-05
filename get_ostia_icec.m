function [icec] = get_ostia_icec(year, day);
global file_info par_info return_flag;

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

% Assign file and parameter information to variable names.
dir_ostia  = file_info.dir_ostia; 
name_ostia = file_info.name_ostia;        

mjd=date2mjd(year,day);
[year, dayinmonth, month]=mjd2date(mjd);

datestring=[num2str(year) num2str_pad_zeros(month,2) ...
            num2str_pad_zeros(dayinmonth,2)];

netcdf_file=[dir_ostia datestring name_ostia];

disp(['*** Opening ' netcdf_file ' and reading sea_ice_fraction']);

icec = ncread(netcdf_file, 'sea_ice_fraction');
