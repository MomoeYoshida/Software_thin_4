function [ok]= write_ghrsst_gds2( year, jday, sst_analysis, error_analysis);

% Date: Sept 18, 2013
% Programmer: D. Frey (SSAI)
% Modification CCR2281: Replaced METOPA with METOPB
%                       Replaced GAC with FRAC for METOPB.

global file_info par_info

init_par_info;
init_file_info;

ok=0; % Completion flag

% Declare file names and paths 

dir_GHRSST=file_info.dir_GHRSST;
dir_ancillary=file_info.dir_ancillary;
dir_ice_hires=file_info.dir_ice_hires;
dir_ice_lores=file_info.dir_ice_lowres;

name_ice_hires = file_info.name_ice_hires;
name_ice_lores = file_info.name_ice_lowres;
name_land_mask= file_info.name_land_mask;


% Declare other variables

scale_factor = 0.01;
hires=1;  % Use hires icemask

sst_FillVal=-32768;
ice_FillVal=-128;
sst_max_val=40;
sst_min_val=-2;
err_max_val=5;
err_min_val=0;
ice_max_val=100;
ice_min_val=0;
add_offset=273.15;


% Get file creation date

date_created=datestr(now, 'yyyymmddTHHMMSSZ');
%date_created=datestr(now, 'yyyy-mm-dd UTC');
date_created_xml=datestr(now, 'yyyy-mm-dd');


% Get start date/time of data 

mjd=date2mjd(year, jday);
[year, day, month]=mjd2date(mjd);


% Pad month/day to two digits if necessary

dstring=num2str_pad_zeros(day, 2);
mstring=num2str_pad_zeros(month, 2);
ystring=num2str(year);

datestring = [ystring mstring dstring];
timestring = '000000';

start_date=[ystring '-' mstring '-' dstring ' UTC'];
start_time = [ystring mstring dstring 'T000000Z'];
start_date_xml = start_time;



% Get stop date/time of data

if ((jday==365) & (mod(year,4)==0))
   tomorrow=366;
   tyear=year;
else
   if (jday==365)
     tomorrow=001;
     tyear=year+1;
   else
     tomorrow=jday+1;
     tyear=year;
   end
end


mjd=date2mjd(tyear, tomorrow);
[tyear, tday, tmonth] = mjd2date(mjd);

% Pad month/day to two digits if necessary

tdstring=num2str_pad_zeros(tday, 2);
tmstring=num2str_pad_zeros(tmonth, 2);
tystring=num2str(tyear);

stop_date = [tystring '-' tmstring '-' tdstring ' UTC'];
stop_time = [tystring tmstring tdstring 'T000000Z'];
stop_date_xml = stop_time;


% Generate a UUID to be included in the global attributes

uuid_string=char(java.util.UUID.randomUUID());

 
% Filename variables

RDAC='OSPO';
PLevel='L4';
PROD='Geo_Polar_Blended';
CHAR='GLOB';
VER='v02.0';
FVer='fv01.0';
Pver='v1.0';
CDFx='.nc';
XMLx='.xml';
FR='FR';
SSType = 'SSTfnd';


% String together filename

id_string=[RDAC '-' PLevel '_GHRSST-' SSType '-' PROD '-' CHAR];
nc_filename=[datestring timestring '-' id_string '-' VER '-' FVer CDFx];
xml_filename=[FR '-' datestring '-' id_string '-' VER '-' FVer '-' PROD XMLx];
entry_id=[PROD '-' RDAC '-' PLevel '-' CHAR '-' Pver];

% Create metadata link name

metadata_URL=['http://podaac.jpl.nasa.gov:8890/ws/metadata/dataset?format=iso&shortName=' entry_id];


% Scale all max/min values

sst_max_val = sst_max_val/scale_factor;
sst_min_val = sst_min_val/scale_factor;
err_max_val = err_max_val/scale_factor;
err_min_val = err_min_val/scale_factor;


% Create lat/lon arrays

latitude = [-89.975:.05:89.975];
longitude = [-179.975:.05:179.975];


% Get seconds since 1981-01-01

t=datenum([datestring ' 120000'],'yyyymmdd HHMMSS');
t0=datenum('19810101 000000','yyyymmdd HHMMSS');
time_Greg=round((t-t0)*86400);


% Get netCDF libraries version

nc_lib_ver=netcdf.inqLibVers;


% Create netCDF file

nc_filename_wpath=[dir_GHRSST nc_filename];
disp(['*** Creating NetCDF file ' nc_filename_wpath]);


% Define dimensions

nccreate(nc_filename_wpath,'time',...
              'Dimensions',{'time' 1},...
	      'Datatype','int32');

 
nccreate(nc_filename_wpath,'lat',...
              'Dimensions',{'lat' 3600},...
	      'Datatype','single');

		  
nccreate(nc_filename_wpath,'lon',...
              'Dimensions',{'lon' 7200},...
	      'Datatype','single');


% Define variables 

nccreate(nc_filename_wpath,'analysed_sst',...
              'Dimensions',{'lon' 7200 'lat' 3600 'time' 1},...
	        'Datatype','int16',...
		'FillValue', int16(sst_FillVal));

nccreate(nc_filename_wpath,'analysis_error',...
              'Dimensions',{'lon' 7200 'lat' 3600 'time' 1},...
	      'Datatype','int16',...
	      'FillValue', int16(sst_FillVal));
		  
nccreate(nc_filename_wpath,'sea_ice_fraction',...
              'Dimensions',{'lon' 7200 'lat' 3600 'time' 1},...
              'Datatype','int8',...
	      'FillValue', int8(ice_FillVal));
	      
nccreate(nc_filename_wpath,'mask',...
              'Dimensions',{'lon' 7200 'lat' 3600 'time' 1},...
	      'Datatype','int8',...
	      'FillValue',int8(0));

% Write the data and attributes to the netCDF file

%%%% time

ncwrite(nc_filename_wpath,'time', time_Greg);

ncwriteatt(nc_filename_wpath,'time','long_name', 'reference time of sst field');
ncwriteatt(nc_filename_wpath,'time','standard_name','time');
ncwriteatt(nc_filename_wpath,'time','axis','T');
ncwriteatt(nc_filename_wpath,'time','calendar','Gregorian');
ncwriteatt(nc_filename_wpath,'time','units','seconds since 1981-01-01 00:00:00');
ncwriteatt(nc_filename_wpath,'time','comment','Nominal time of Level 4 analysis');


%%%% latitude

ncwrite(nc_filename_wpath,'lat', latitude);

ncwriteatt(nc_filename_wpath,'lat','long_name','latitude');
ncwriteatt(nc_filename_wpath,'lat','standard_name','latitude');
ncwriteatt(nc_filename_wpath,'lat','units','degrees_north');
ncwriteatt(nc_filename_wpath,'lat','axis','Y');
ncwriteatt(nc_filename_wpath,'lat','valid_min', single(-90));
ncwriteatt(nc_filename_wpath,'lat','valid_max', single(90));
ncwriteatt(nc_filename_wpath,'lat','comment','equirectangular projection');


%%%% longitude

ncwrite(nc_filename_wpath,'lon', longitude);

ncwriteatt(nc_filename_wpath,'lon','long_name','longitude');
ncwriteatt(nc_filename_wpath,'lon','standard_name','longitude');
ncwriteatt(nc_filename_wpath,'lon','units','degrees_east');
ncwriteatt(nc_filename_wpath,'lon','axis','X');
ncwriteatt(nc_filename_wpath,'lon','valid_min', single(-180));
ncwriteatt(nc_filename_wpath,'lon','valid_max', single(180));
ncwriteatt(nc_filename_wpath,'lon','comment','equirectangular projection');


%%%% analysed_sst

sst_scaled=(sst_analysis/scale_factor);
sst_int=int16(sst_scaled);
sst_trans=sst_int'; %transpose the matrix so it matches variable dimensions

ncwrite(nc_filename_wpath,'analysed_sst', sst_trans);

ncwriteatt(nc_filename_wpath,'analysed_sst','long_name','analysed sea surface temperature');
ncwriteatt(nc_filename_wpath,'analysed_sst','standard_name','sea_surface_foundation_temperature');
ncwriteatt(nc_filename_wpath,'analysed_sst','units', 'kelvin');
ncwriteatt(nc_filename_wpath,'analysed_sst','add_offset', single(add_offset));
ncwriteatt(nc_filename_wpath,'analysed_sst','scale_factor', single(scale_factor));
ncwriteatt(nc_filename_wpath,'analysed_sst','valid_min', int16(sst_min_val));
ncwriteatt(nc_filename_wpath,'analysed_sst','valid_max', int16(sst_max_val));
ncwriteatt(nc_filename_wpath,'analysed_sst','coordinates', 'lon lat');
ncwriteatt(nc_filename_wpath,'analysed_sst','reference', 'Fieguth,P.W. et al. "Mapping Mediterranean altimeter data with a multiresolution optimal interpolation algorithm", J. Atmos. Ocean Tech, 15 (2): 535-546, 1998.     Fieguth, P. Multiply-Rooted Multiscale Models for Large-Scale Estimation, IEEE Image Processing, 10(11), 1676-1686, 2001.     Khellah, F., P.W. Fieguth, M.J. Murray and M.R. Allen, "Statistical Processing of Large Image Sequences", IEEE Transactions on Geoscience and Remote Sensing, 12 (1), 80-93, 2005.');
ncwriteatt(nc_filename_wpath,'analysed_sst','source','OSPO-ACSPO_VIIRS, OSPO-ACSPO_METOPB_FRAC, OSPO-GOES16_SST_L3,OSPO-GOES15_SST_L3, OSPO-METEOSAT11_SST_L3, OSPO-METEOSAT08_SST_L3, OSPO-HIMA8_SST_L3');
ncwriteatt(nc_filename_wpath,'analysed_sst','comment','Analysed SST for each ocean grid point');


%%%% analysis_error

error_scaled=error_analysis/scale_factor;
error_int=int16(error_scaled);
error_trans=error_int'; %transpose the matrix so it matches variable dimensions

ncwrite(nc_filename_wpath,'analysis_error', error_trans);

ncwriteatt(nc_filename_wpath,'analysis_error','long_name','estimated error standard deviation of analysed_sst');
ncwriteatt(nc_filename_wpath,'analysis_error','units','kelvin');
ncwriteatt(nc_filename_wpath,'analysis_error','add_offset',single(0.0));
ncwriteatt(nc_filename_wpath,'analysis_error','scale_factor',single(scale_factor));
ncwriteatt(nc_filename_wpath,'analysis_error','valid_min', int16(err_min_val));
ncwriteatt(nc_filename_wpath,'analysis_error','valid_max', int16(err_max_val));
ncwriteatt(nc_filename_wpath,'analysis_error','coordinates', 'lon lat');
ncwriteatt(nc_filename_wpath,'analysis_error','comment','Estimate of internal analysis accuracy');


%%%% sea_ice_fraction 
  
ice_fac=par_info.rtg_fac;
res=1;

disp(['*** Get ice concentration from raw ice mask']);
ice_conc=get_ice_dat(year, jday, res);
ice_conc=rebin(ice_conc, ice_fac(res+1), 'linear');
disp(['*** Ice concentration retrieved']);

ice_scaled=ice_conc/scale_factor;
ice_byte=int8(ice_scaled);
ice_trans=ice_byte';  %transpose the matrix so it matches variable dimensions

ncwrite(nc_filename_wpath,'sea_ice_fraction',ice_trans);

ncwriteatt(nc_filename_wpath,'sea_ice_fraction','long_name','sea ice fraction');
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','standard_name','sea_ice_area_fraction');
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','units', '1');
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','add_offset', single(0.0));
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','scale_factor', single(scale_factor));
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','valid_min', int8(0));
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','valid_max', int8(100));
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','coordinates', 'lon lat');
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','source','NCEP 1/12th degree ice mask');
ncwriteatt(nc_filename_wpath,'sea_ice_fraction','comment',' Percentage of ice');


%%%% mask
disp(['*** Loading Landmask ' dir_ancillary name_land_mask]);
eval(['load ' dir_ancillary name_land_mask ' land_mask ']);
disp(['*** Loaded ' dir_ancillary name_land_mask]);

land=find(land_mask<1);
ice=find(ice_conc>0.5);

land_ice_mask=ones(3600,7200);
land_ice_mask(land)=2;
land_ice_mask(ice)=4;

mask_byte=int8(land_ice_mask);
mask_trans=mask_byte'; %transpose the matrix so it matches variable dimensions


flag_value_string=[int8(1), int8(2), int8(4)];
mask_comment=['b0: 1=grid cell is water, b1: 1=grid cell is land, b2: 1=grid cell is ice'];

ncwrite(nc_filename_wpath,'mask',mask_trans);

ncwriteatt(nc_filename_wpath,'mask','long_name','sea/land/ice bit mask');
ncwriteatt(nc_filename_wpath,'mask','standard_name','sea_land_ice_bit_mask');
ncwriteatt(nc_filename_wpath,'mask','flag_values', int8(flag_value_string));
ncwriteatt(nc_filename_wpath,'mask','flag_meanings','water land ice');
ncwriteatt(nc_filename_wpath,'mask','valid_min',int8(1));
ncwriteatt(nc_filename_wpath,'mask','valid_max',int8(4));
ncwriteatt(nc_filename_wpath,'mask','coordinates', 'lon lat');
ncwriteatt(nc_filename_wpath,'mask','source',' NCEP 1/12th degree ice mask, OSTIA land mask');
ncwriteatt(nc_filename_wpath,'mask','comment',mask_comment);


% Create global attributes

ncwriteatt(nc_filename_wpath,'/','Conventions','CF-1.4, Unidata Observation Dataset v1.0');
ncwriteatt(nc_filename_wpath,'/','title','Analysed blended sea surface temperature over the global ocean using day and night input data');
ncwriteatt(nc_filename_wpath,'/','summary', 'An SST estimation scheme which combines multi-satellite retrievals of sea surface temperature datasets available from polar orbiters, geostationary IR and microwave sensors into a single global analysis. This global SST ananlysis provide a daily gap free map of the foundation sea surface temperature at 0.05o spatial resolution.');
ncwriteatt(nc_filename_wpath,'/','references','Fieguth,P.W. et al. "Mapping Mediterranean altimeter data with a multiresolution optimal interpolation algorithm", J. Atmos. Ocean Tech, 15 (2): 535-546, 1998.     Fieguth, P. Multiply-Rooted Multiscale Models for Large-Scale Estimation, IEEE Image Processing, 10(11), 1676-1686, 2001.     Khellah, F., P.W. Fieguth, M.J. Murray and M.R. Allen, "Statistical Processing of Large Image Sequences", IEEE Transactions on Geoscience and Remote Sensing, 12 (1), 80-93, 2005.');
ncwriteatt(nc_filename_wpath,'/','institution','Office of Satellite Products and Operations');
ncwriteatt(nc_filename_wpath,'/','history','NESDIS geo-SST L1 to L2 processor, NESDIS Advanced Clear-Sky Processor for Oceans (ACSPO), NESDIS Geo-Polar 1/20th degree Blended SST Analysis');
ncwriteatt(nc_filename_wpath,'/','comment','The Geo-Polar Blended Sea Surface Temperature (SST) Analysis combines multi-satellite retrievals of sea surface temperature into a single analysis of SST');
ncwriteatt(nc_filename_wpath,'/','license','GHRSST protocol describes data use as free and open');
ncwriteatt(nc_filename_wpath,'/','id', entry_id);
ncwriteatt(nc_filename_wpath,'/','naming_authority','org.ghrsst');
ncwriteatt(nc_filename_wpath,'/','product_version','1.0');
ncwriteatt(nc_filename_wpath,'/','uuid',uuid_string);
ncwriteatt(nc_filename_wpath,'/','gds_version_id','2.0');
ncwriteatt(nc_filename_wpath,'/','netcdf_version_id', nc_lib_ver);
ncwriteatt(nc_filename_wpath,'/','date_created', date_created);
ncwriteatt(nc_filename_wpath,'/','start_time', start_time);
ncwriteatt(nc_filename_wpath,'/','time_coverage_start',start_time);
ncwriteatt(nc_filename_wpath,'/','stop_time', stop_time);
ncwriteatt(nc_filename_wpath,'/','time_coverage_end', stop_time);
ncwriteatt(nc_filename_wpath,'/','file_quality_level',0);
ncwriteatt(nc_filename_wpath,'/','source','OSPO-ACSPO_VIIRS, OSPO-ACSPO_METOPB_FRAC, OSPO-GOES16_SST_L3, OSPO-GOES15_SST_L3, OSPO-METEOSAT11_SST_L3, OSPO-METEOSAT08_SST_L3, OSPO-HIMA8_SST_L3');
ncwriteatt(nc_filename_wpath,'/','platform',['Suomi NPP, MetOp-B, ' par_info.goese, ', ', par_info.goesw,', Meteosat-11, Meteosat-08, ', par_info.mtsat]);
ncwriteatt(nc_filename_wpath,'/','sensor','VIIRS, AVHRR, ABI, Imager, SEVIRI, SEVIRI, AHI');
ncwriteatt(nc_filename_wpath,'/','Metadata_Conventions','Unidata Observation Dataset v1.0');
ncwriteatt(nc_filename_wpath,'/','metadata_link',metadata_URL);
ncwriteatt(nc_filename_wpath,'/','keywords','Oceans > Ocean Temperature > Sea Surface Temperature');
ncwriteatt(nc_filename_wpath,'/','keywords_vocabulary','NASA Global Change Master Directory (GCMD) Science Keywords');
ncwriteatt(nc_filename_wpath,'/','standard_name_vocabulary','NetCDF Climate and Forecast (CF) Metadata Convetion');
ncwriteatt(nc_filename_wpath,'/','westernmost_longitude',single(-180.));
ncwriteatt(nc_filename_wpath,'/','easternmost_longitude',single(180.));
ncwriteatt(nc_filename_wpath,'/','southernmost_latitude',single(-90.));
ncwriteatt(nc_filename_wpath,'/','northernmost_latitude', single(90.));
ncwriteatt(nc_filename_wpath,'/','spatial_resolution','0.05 degree');
ncwriteatt(nc_filename_wpath,'/','geospatial_lat_units','degrees north');
ncwriteatt(nc_filename_wpath,'/','geospatial_lat_resolution','0.05');
ncwriteatt(nc_filename_wpath,'/','geospatial_lon_units','degrees east');
ncwriteatt(nc_filename_wpath,'/','geospatial_lon_resolution','0.05');
ncwriteatt(nc_filename_wpath,'/','acknowledgment','NOAA/NESDIS');
ncwriteatt(nc_filename_wpath,'/','creator_name','Office of Satellite Products and Operations');
ncwriteatt(nc_filename_wpath,'/','creator_email','john.sapper@noaa.gov');
ncwriteatt(nc_filename_wpath,'/','creator_url','www.osdpd.nesdis.noaa.gov');
ncwriteatt(nc_filename_wpath,'/','project','Group for High Resolution Sea Surface Temperature');
ncwriteatt(nc_filename_wpath,'/','publisher_name','The GHRSST Project Office');
ncwriteatt(nc_filename_wpath,'/','publisher_url','http://www.ghrsst.org');
ncwriteatt(nc_filename_wpath,'/','publisher_email','ghrsst-po@nceo.ac.uk');
ncwriteatt(nc_filename_wpath,'/','processing_level','L4');
ncwriteatt(nc_filename_wpath,'/','cdm_data_type','grid');


% Return 1 on successful completion
ok = 1;

% No longer need to create XML file to accompany netCDF4 file.


% Write XML file

%xml_filename_wpath=[dir_GHRSST xml_filename];

%disp(['*** Creating XML file ' xml_filename_wpath]);
%XMLID = fopen(xml_filename_wpath, 'w+');
%XMLID

%fprintf(XMLID, '%s\n', '<?xml version="1.0" encoding="UTF-8"?>');
%fprintf(XMLID, '%s\n', '<!DOCTYPE MMR_FR SYSTEM "mmr_fr.dtd">');
%fprintf(XMLID, '%s\n', '<MMR_FR>');
%fprintf(XMLID, '%s%s%s\n', '<Entry_ID>',entry_id, '</Entry_ID>');
%fprintf(XMLID, '%s%s%s\n', '<File_Name>',nc_filename,'</File_Name>');
%fprintf(XMLID, '%s%s%s\n', '<File_Release_Date>', date_created, '</File_Release_Date>');
%fprintf(XMLID, '%s\n', '<File_Version>1.0</File_Version>');
%fprintf(XMLID, '%s\n', '<Related_URL>');
%fprintf(XMLID, '%s\n', '<URL>http://www.osdpd.noaa.gov/ml/ocean/sst/blended_sst.html</URL>');
%fprintf(XMLID, '%s\n', '<Description>Home page for OSPO GOES-POES Blended SST </Description>');
%fprintf(XMLID, '%s\n', '</Related_URL>');
%fprintf(XMLID, '%s\n', '<Temporal_Coverage>');
%fprintf(XMLID, '%s%s%s\n', '<Start_Date>',start_date_xml,'</Start_Date>');
%fprintf(XMLID, '%s%s%s\n', '<Stop_Date>',stop_date_xml,'</Stop_Date>');
%fprintf(XMLID, '%s\n', '</Temporal_Coverage>');
%fprintf(XMLID, '%s\n', '<Spatial_Coverage>');
%fprintf(XMLID, '%s\n', '<Southernmost_Latitude>-90.00</Southernmost_Latitude>');
%fprintf(XMLID, '%s\n', '<Northernmost_Latitude>90.00</Northernmost_Latitude>');
%fprintf(XMLID, '%s\n', '<Westernmost_Longitude>-180.00</Westernmost_Longitude>');
%fprintf(XMLID, '%s\n', '<Easternmost_Longitude>180.00</Easternmost_Longitude>');
%fprintf(XMLID, '%s\n', '</Spatial_Coverage>');
%fprintf(XMLID, '%s\n', '<Personnel>');
%fprintf(XMLID, '%s\n', '<Role>Tecnhical Contact</Role>');
%fprintf(XMLID, '%s\n', '<First_Name>Eileen</First_Name>');
%fprintf(XMLID, '%s\n', '<Last_Name>Maturi</Last_Name>');
%fprintf(XMLID, '%s\n', '<Email>eileen.maturi@noaa.gov</Email>');
%fprintf(XMLID, '%s\n', '<Phone>301-763-8102 x172</Phone>');
%fprintf(XMLID, '%s\n', '<Fax>301-763-8527</Fax>');
%fprintf(XMLID, '%s\n', '<Address>5200 Auth Road Room 601, Suitland, MD 20746-4325</Address>');
%fprintf(XMLID, '%s\n', '</Personnel>');
%fprintf(XMLID, '%s\n', '<Metadata_History>');
%fprintf(XMLID, '%s\n', '<FR_File_Version>1.0</FR_File_Version>');
%fprintf(XMLID, '%s%s%s\n', '<FR_Creation_Date>', date_created,'</FR_Creation_Date>');
%fprintf(XMLID, '%s%s%s\n', '<FR_Last_Revision_Date>',date_created,'</FR_Last_Revision_Date>');
%fprintf(XMLID, '%s%s%s%s\n', '<FR_Revision_History>', date_created_xml, ', First created','</FR_Revision_History>');
%fprintf(XMLID, '%s\n', '</Metadata_History>');
%fprintf(XMLID, '%s\n', '</MMR_FR>');


