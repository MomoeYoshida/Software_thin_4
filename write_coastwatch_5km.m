function [ok]=  write_coastwatch_5km( hdf_filename, year, day, sst_analysis, error_analysis, ...
                                  land_mask, ice_mask, processing_date, bad_val, max_val, min_val);

% Function to write daily output file from NOAA Hires Operational SST Analysis
%   in coastwatch format.
% Two arrays, sst_analysis and error_analysis containing SST analysis and associated
%   error analysis are stored, together with metadata as required by COASTWATCH HDF format
%   description.
%
% Combined land/ice mask is put into the HDF file
%
% in the original land_mask: 	
%               0 is land		    (0x00)
%				2 is pacific ocean	(0x02)
%				3 is atalantic ocean(0x03)
%				5 is indian ocean	(0x05)
%				6 is arctic		    (0x06)
%				7 is antarctic		(0x07)
%
% in the original ice_mask: 	
%               0 is water		(0x00)
%				1 is ice		(0x01)
%				2 is land		(0x02)
%
% to use cwrender, the new mask is set to new_mask=16*land_mask+4*ice_mask
%   so the landmask is at bit 3 (0x08)
%				4  is ice		        (0x04)
%				8  is land		        (0x08)
%				32 is pacific ocean	    (0x20)
%				48 is atalantic ocean   (0x30)
%				80 is indian ocean	    (0x50)
%				96 is arctic		    (0x60)
%				112 is antarctic 	    (0x70)
%

global file_info par_info

init_par_info;
init_file_info;


import matlab.io.hdf4.*

display 'SETTING UP VARS...';
start_day_night=par_info.start_day_night;
end_day_night=par_info.end_day_night;

scale_factor=1.0;
scale_factor_err=0.0;
add_offset=0.0;
add_offset_err=0.0;
fraction_digits=int32(4);

bad_val=single(bad_val);
max_val=single(max_val);
min_val=single(min_val);

% Work out days since 1 Jan 1970 as used by COASTWATCH.
date_origin=datenum(1970,1,1);
this_date=datenum(year,1,1)+day-1;
pass_date=this_date-date_origin;

% Rotate dataset from matlab y/x to standard x/y orientation.
A=fliplr(single(sst_analysis)');



display 'CREATING DATASET...';
% Create COASTWATCH dataset.
% Create sst_analysis SDS
%sd_id=hdfsd('start', hdf_filename,'DFACC_CREATE');
sd_id = sd.start(hdf_filename,'create');
ds_name='sst_analysis';
ds_type='float32';
ds_rank=ndims(A);
ds_dims=fliplr(size(A));
ds_dims=transpose(ds_dims);
%sds_id=hdfsd('create', sd_id, ds_name, ds_type, ds_rank, ds_dims);
sds_id = sd.create(sd_id, ds_name, ds_type, ds_dims); 
sd.setAttr(sds_id,'missing_value', bad_val);
%status=hdfsd('setattr', sds_id, 'missing_value', bad_val);
sd.setAttr(sds_id,'fraction_digits', fraction_digits);
%status=hdfsd('setattr', sds_id, 'fraction_digits', fraction_digits);
sd.setAttr(sds_id,'scale_factor', scale_factor);
%status=hdfsd('setattr', sds_id, 'scale_factor', scale_factor);
sd.setAttr(sds_id,'scale_factor_error', scale_factor_err);
%status=hdfsd('setattr', sds_id, 'scale_factor_err', scale_factor_err);
sd.setAttr(sds_id,'add_offset_err', add_offset_err);
%status=hdfsd('setattr', sds_id, 'add_offset_err', add_offset_err);
sd.setAttr(sds_id,'add_offset', add_offset);
%status=hdfsd('setattr', sds_id, 'add_offset', add_offset);
sd.setRange(sds_id, max_val, min_val);
%status=hdfsd('setrange', sds_id, max_val, min_val);

% Set label units format coord_system 
if (start_day_night == 0) & (end_day_night == 1) 
  sd.setDataStrs(sds_id, 'blended daily day/night geo polar sst', 'celsius', 'decimal', 'global lat lon');
%  status=hdfsd('setdatastrs', sds_id, 'blended daily day/night geo polar sst', 'celsius', 'decimal', 'global lat lon');
elseif (start_day_night == 1) & (end_day_night == 1)
  sd.setDataStrs(sds_id, 'blended daily night-only geo polar sst', 'celsius', 'decimal', 'global lat lon');
%  status=hdfsd('setdatastrs', sds_id, 'blended daily night-only geo polar sst', 'celsius', 'decimal', 'global lat lon');
end



display 'WRITING DATA...';
ds_start=zeros(1:ndims(A));
ds_stride=[];
ds_edges=fliplr(size(A));
%A=transpose(A);
sd.writeData(sds_id, ds_start, ds_stride, A);
%stat1=hdfsd('writedata',sds_id, ds_start, ds_stride, ds_edges, A);
sd.endAccess(sds_id);
%stat2=hdfsd('endaccess', sds_id);

% Create error_analysis SDS
% Rotate dataset from matlab y/x to standard x/y orientation.
A=fliplr(single(error_analysis)');
ds_name='error_analysis';

%sds_id=hdfsd('create', sd_id, ds_name, ds_type, ds_rank, ds_dims);
sds_id = sd.create(sd_id, ds_name, ds_type, ds_dims);

sd.setAttr(sds_id,'missing_value', bad_val);
sd.setAttr(sds_id,'fraction_digits', fraction_digits);
sd.setAttr(sds_id,'scale_factor', scale_factor);
sd.setAttr(sds_id,'scale_factor_error', scale_factor_err);
sd.setAttr(sds_id,'add_offset_err', add_offset_err);
sd.setAttr(sds_id,'add_offset', add_offset);
sd.setDataStrs(sds_id, 'sst_error', 'celsius', 'decimal', 'global lat lon');
%status=hdfsd('setdatastrs', sds_id, 'sst error', 'celsius', 'decimal', 'global lat lon');

ds_start=zeros(1:ndims(A));
ds_stride=[];
ds_edges=fliplr(size(A));
%stat1=hdfsd('writedata',sds_id, ds_start, ds_stride, ds_edges, A);
%A=transpose(A);
sd.writeData(sds_id, ds_start, ds_stride, A);
sd.endAccess(sds_id);

%stat2=hdfsd('endaccess', sds_id);

% Create mask SDS
% combine land_mask and ice_mask by shifting land_maks left 4 bit
% because ice_mask takes only three least significant bits (0 for water, 1(4) for ice, 2(8) for land)

mask=16*uint8(land_mask)+4*uint8(ice_mask);

% Rotate dataset from matlab y/x to standard x/y orientation.
mask=fliplr(mask');
ds_name='graphics';
ds_type='uint8';

sds_id = sd.create(sd_id, ds_name, ds_type, ds_dims);

%sds_id=hdfsd('create', sd_id, ds_name, ds_type, ds_rank, ds_dims);

% Set label units format coord_system 
%status=hdfsd('setdatastrs', sds_id, 'land ice water mask', 'none', 'decimal', 'global lat lon');
sd.setDataStrs(sds_id, 'land ice water mask', 'none', 'decimal', 'global lat lon');

ds_start=zeros(1:ndims(mask));
ds_stride=[];
ds_edges=fliplr(size(mask));
%stat1=hdfsd('writedata',sds_id, ds_start, ds_stride, ds_edges, mask);
%mask=transpose(mask);
sd.writeData(sds_id, ds_start, ds_stride, mask);
%stat2=hdfsd('endaccess', sds_id);
sd.endAccess(sds_id);



display 'WRITING METADATA...'
% Write metadata to file.
sds_id=sd_id;
 
% Specify satellite datasets used.
newline=char(12);
satellite_names=['metop-b ', par_info.goese, ' ', par_info.goesw, ' msg/', par_info.mtsat, ' npp'];
%status=hdfsd('setattr', sds_id, 'satellite', satellite_names);
sd.setAttr(sds_id,'satellite', satellite_names);

% Specify sensor used.
satellite_sensor=['npp viirs, metop-b avhrr, goese/w imager, msg seviri, mtsat imager'];
%status=hdfsd('setattr', sds_id, 'sensor', satellite_sensor);
sd.setAttr(sds_id, 'sensor', satellite_sensor);
% Specify input data used
if (start_day_night == 0) & (end_day_night == 1) 
  fid=fopen('/prod/GOES/5KM_BLENDED/DAY_NIGHT/Data/sateinfo','rt');
elseif (start_day_night == 1) & (end_day_night == 1) 
  fid=fopen('/prod/GOES/5KM_BLENDED/NIGHT_ONLY/Data/sateinfo','rt');
end
input_pixels_used = fgetl(fid);
%status=hdfsd('setattr', sds_id, 'input pixels used', input_pixels_used);
sd.setAttr(sds_id,  'input pixels used', input_pixels_used);

%status=hdfsd('setattr', sds_id, 'origin', 'USDOC/NOAA/NESDIS COASTWATCH');
sd.setAttr(sds_id, 'origin', 'USDOC/NOAA/NESDIS COASTWATCH');
history_text=['writecoastwatch Produced by NOAA Blended SST Analysis Processing on ' processing_date];
%status=hdfsd('setattr', sds_id, 'history', history_text);
%status=hdfsd('setattr', sds_id, 'cwhdf_version', '3.4');
%status=hdfsd('setattr', sds_id, 'pass_date', int32(pass_date));
%status=hdfsd('setattr', sds_id, 'start_time', 0);
%status=hdfsd('setattr', sds_id, 'temporal_extent', 86399);
%status=hdfsd('setattr', sds_id, 'pass_type', 'day');

sd.setAttr(sds_id, 'history', history_text);
sd.setAttr(sds_id, 'cwhdf_version', '3.4');
sd.setAttr(sds_id, 'pass_date', int32(pass_date));
sd.setAttr(sds_id, 'start_time', 0);
sd.setAttr(sds_id, 'temporal_extent', 86399);
sd.setAttr(sds_id, 'pass_type', 'day');

polygon_latitude=[90 90 90 0 -90 -90 -90 0 90];
polygon_longitude=[-180 0 180 180 180 0 -180 -180 -180];
et_affine=[0.0 -0.05 0.05 0.0 -179.975 89.975];

%status=hdfsd('setattr', sds_id, 'rows', int32(3600));
%status=hdfsd('setattr', sds_id, 'cols', int32(7200));
%status=hdfsd('setattr', sds_id, 'projection_type', 'mapped');
%status=hdfsd('setattr', sds_id, 'projection', 'geographic');
%status=hdfsd('setattr', sds_id, 'gctp_sys', int32(0));
%status=hdfsd('setattr', sds_id, 'gctp_zone', int32(0));
%status=hdfsd('setattr', sds_id, 'gctp_parm', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]);
%status=hdfsd('setattr', sds_id, 'gctp_datum', int32(12));
%status=hdfsd('setattr', sds_id, 'et_affine', et_affine);

sd.setAttr(sds_id, 'rows', int32(3600));
sd.setAttr(sds_id, 'cols', int32(7200));
sd.setAttr(sds_id, 'projection_type', 'mapped');
sd.setAttr(sds_id, 'projection', 'geographic');
sd.setAttr(sds_id, 'gctp_sys', int32(0));
sd.setAttr(sds_id, 'gctp_zone', int32(0));
sd.setAttr(sds_id, 'gctp_parm', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]);
sd.setAttr(sds_id, 'gctp_datum', int32(12));
sd.setAttr(sds_id, 'et_affine', et_affine); 

display 'DONE...';
%ok=hdfsd('end', sd_id);
sd.close(sd_id);
ok=1
