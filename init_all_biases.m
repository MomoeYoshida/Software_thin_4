
function init_all_biases(year,day);
% create all initial bias data by setting all values zero
% H. Gu January 22, 2008

global file_info par_info return_flag
global yesterday

return_flag=1;

disp(['*** create initial bias corrections '])

today=get_datestring(year,day);

% Get information about file locations and names and parameters.

init_file_info;
init_par_info;

spatial_resolution=par_info.spatial_resolution;

% Use global file_info structure as defined by init_file_info.m to 
% determine information about directories and filename.

name_sst_biases          = file_info.name_sst_biases;

amsr2_day_bias=zeros(spatial_resolution);
amsr2_night_bias=zeros(spatial_resolution);
viirs_day_c0_bias=zeros(spatial_resolution);
viirs_night_c0_bias=zeros(spatial_resolution);
jpss_day_c0_bias=zeros(spatial_resolution);
jpss_night_c0_bias=zeros(spatial_resolution);
METOPA_day_c0_bias=zeros(spatial_resolution);
METOPB_day_c0_bias=zeros(spatial_resolution);
METOPC_day_c0_bias=zeros(spatial_resolution);
METOPA_night_c0_bias=zeros(spatial_resolution);
METOPB_night_c0_bias=zeros(spatial_resolution);
METOPC_night_c0_bias=zeros(spatial_resolution);
goese_day_bias=zeros(spatial_resolution);
goese_night_bias=zeros(spatial_resolution);
goesw_day_bias=zeros(spatial_resolution);
goesw_night_bias=zeros(spatial_resolution);
msg_day_bias=zeros(spatial_resolution);
msg_night_bias=zeros(spatial_resolution);
mio_day_bias=zeros(spatial_resolution);
mio_night_bias=zeros(spatial_resolution);
mtsat_day_bias=zeros(spatial_resolution);
mtsat_night_bias=zeros(spatial_resolution);
slstra_day_bias=zeros(spatial_resolution);
slstra_night_bias=zeros(spatial_resolution);
slstrb_day_bias=zeros(spatial_resolution);
slstrb_night_bias=zeros(spatial_resolution);
ostia_bias=zeros(spatial_resolution);

eval(['save ' file_info.dir_analysis name_sst_biases today ' *bias'])

