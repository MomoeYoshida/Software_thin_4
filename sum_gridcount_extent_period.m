function sum_gridcount_extent_period(extent, start_date, end_date);
% -------------------------------------------------------------------------
% NAME:
%   sum_gridcount_extent_period
%
% DESCRIPTION:
%   Calculate and visualise total nighttime gridcount for a region and 
%   period. Also, calculate percentiles. This is useful when you want to
%   identify sites with higher/lower data density (gridcount) during a
%   certain period.
%
% PSEUDO CODE
%
%
%
% INPUTS:
%   extent      = [lon_min lon_max lat_min lat_max]  (e.g., [140 155 -25 -10])
%   start_date  = numeric_yyyymmdd, e.g. 20250111
%   end_date  = numeric_yyyymmdd, e.g. 20250331
%
% REQUIREMENTS/INPUT DATA:
%   - MATLAB .mat files named as: sum_night_gridcount_YYYY_DDD.mat
%   - Each contains a variable 'num_sum' (3600x7200)
%
% OUTPUTS:
%
%
% Author: Momoe R. Yoshida
% Date: 12/11/2025
%
% -------------------------------------------------------------------------

% ----User Input---------------------------------
cluster = 0; % True=1, False=0

% Sites of interest
sites_lons = [145.5136, 151.4849, 146.48, 149.38]
sites_lats = [-14.7435, -23.9583, -18.569, -19.764]
% -----------------------------------------------

%% Initialise

global file_info par_info blended_sst_home
init_file_info;  
init_par_info;

data_dir = file_info.dir_analysis;
out_prefix = 'extent_period_sum_night_gridcount';
varname = 'num_sum';
val_cl = 'w'; % color of values on the map


start_date = datetime(start_date, 'ConvertFrom', 'yyyymmdd'); % for numeric yyyymmdd values
end_date = datetime(end_date, 'ConvertFrom', 'yyyymmdd');

%TNT: Improve to work for crossing multi years
yoa = year(start_date); % year of analysis
start_doy = day(start_date, 'dayofyear');
end_doy = day(end_date, 'dayofyear');

spatial_resolution = par_info.spatial_resolution; %=[3600,7200]
nx = spatial_resolution(2);
ny = spatial_resolution(1);
pix_res = 180/ny;

% Define lon/lat consistent with data orientation
lon = linspace(-180 + pix_res/2, 180 - pix_res/2, nx);
lat = linspace(-90 + pix_res/2, 90 - pix_res/2, ny); % ascending (south→north)

fprintf('\nSumming gridcounts for %d–%d (%d days)\n', ...
    start_doy, end_doy, end_doy - start_doy + 1);

% Initialize accumulation array
sum_grid = zeros(spatial_resolution);


%% Loop through each Julian day file
for doy = start_doy:end_doy
    filename = sprintf('sum_night_gridcount_%04d_%03d.mat', yoa, doy);
    filepath = fullfile(data_dir, filename);
    if ~isfile(filepath)
        warning('File not found: %s (skipping)', filename);
        continue
    end

    S = load(filepath, varname);
    if ~isfield(S, varname)
        warning('%s not found in %s', varname, filename);
        continue
    end
    arr = double(S.(varname));

    % Ensure orientation (lat x lon)
    if isequal(size(arr), [nx, ny]) % transposed
        arr = arr.';
    elseif ~isequal(size(arr), [ny, nx]) % checks if the array has neither shape [nx, ny] nor [ny, nx]
        error('Unexpected array size in %s: %s', filename, mat2str(size(arr)));
    end

    sum_grid = sum_grid + arr;
end

%% Subset region
lon_min = extent(1); lon_max = extent(2);
lat_min = extent(3); lat_max = extent(4);

% Debug----------------------------------------------------------------------
fprintf('Extent: lon %.1f–%.1f, lat %.1f–%.1f\n', lon_min, lon_max, lat_min, lat_max);
fprintf('lon(1)=%.1f, lon(end)=%.1f\n', lon(1), lon(end));
fprintf('lat(1)=%.1f, lat(end)=%.1f\n', lat(1), lat(end));
% Debug End----------------------------------------------------------------------

[~, ixmin] = min(abs(lon - lon_min));
[~, ixmax] = min(abs(lon - lon_max));
[~, iymin] = min(abs(lat - lat_min));
[~, iymax] = min(abs(lat - lat_max));

% Debug----------------------------------------------------------------------
fprintf('ixmin=%d, ixmax=%d, iymin=%d, iymax=%d\n', ixmin, ixmax, iymin, iymax);
% Debug End----------------------------------------------------------------------

region_data = sum_grid(iymin:iymax, ixmin:ixmax);
region_lon = lon(ixmin:ixmax);
region_lat = lat(iymin:iymax);

% Debug----------------------------------------------------------------------
fprintf('Region subset size: %dx%d\n', size(region_data,1), size(region_data,2));
fprintf('Non-NaN values in region: %d\n', sum(~isnan(region_data(:))));
% Debug End----------------------------------------------------------------------

%% Percentiles within the extent
vals = region_data(:);
vals(isnan(vals)) = [];
p95 = prctile(vals, 95);
p50 = prctile(vals, 50);
p05 = prctile(vals, 5); %TNT: except 0s

fprintf('Percentiles (5th, 50th, 95th): %.1f, %.1f, %.1f\n', p05, p50, p95);

if cluster
    disp('Clustering enabled: generating percentile masks and centroids...');
    % ---- Build percentile masks ----
    mask95 = region_data >= p95;
    mask50 = region_data >= p50 & region_data < p95;   % middle band
    mask05 = region_data <= p05;
    
    [Xgrid, Ygrid] = meshgrid(region_lon, region_lat);
    
    pts95 = [Xgrid(mask95), Ygrid(mask95)];
    pts50 = [Xgrid(mask50), Ygrid(mask50)];
    pts05 = [Xgrid(mask05), Ygrid(mask05)];
    
    % ---- KMEANS CLUSTERING (3 clusters each) ----
    opts = statset('MaxIter', 1000);
    
    if size(pts95,1) >= 3
        [idx95, c95] = kmeans(pts95, 3, 'Options', opts, 'Replicates',5);
    else
        c95 = NaN(3,2);
    end
    
    if size(pts50,1) >= 3
        [idx50, c50] = kmeans(pts50, 3, 'Options', opts, 'Replicates',5);
    else
        c50 = NaN(3,2);
    end
    
    if size(pts05,1) >= 3
        [idx05, c05] = kmeans(pts05, 3, 'Options', opts, 'Replicates',5);
    else
        c05 = NaN(3,2);
    end
    
    % Store centroid outputs
    p95_mask_centroids = array2table(c95, 'VariableNames',{'Lon','Lat'});
    p50_mask_centroids = array2table(c50, 'VariableNames',{'Lon','Lat'});
    p05_mask_centroids = array2table(c05, 'VariableNames',{'Lon','Lat'});
end


%% Visualization
figure('Position',[100 100 900 700]);
imagesc(region_lon, region_lat, region_data);
set(gca, 'YDir', 'normal');
axis tight; xlabel('Longitude'); ylabel('Latitude');
title(sprintf('Gridcount Sum: %s–%s', datestr(start_date), datestr(end_date)));
cb = colorbar; cb.Label.String = 'Total gridcount';
colormap(parula);

hold on;
[X,Y] = meshgrid(region_lon, region_lat);

% Sites of interest, nearest-pixel extraction
site_values = nan(length(sites_lons),1);
pos = 6; % position of labels
for s = 1:length(sites_lons)

    % Find nearest lon/lat index inside the region
    [~, ix] = min(abs(region_lon - sites_lons(s)));
    [~, iy] = min(abs(region_lat - sites_lats(s)));

    % Extract value
    val = region_data(iy, ix);
    site_values(s) = val;

    % Plot on map
    plot(region_lon(ix), region_lat(iy), 'ro', ...
        'MarkerSize', 8, 'LineWidth', 1.5);

    % Add label (value)
    text(lon_min+0.2, lat_min+pos, ...
         sprintf('(%.4f, %.4f): %.0f', sites_lons(s), sites_lats(s), val), ...
         'Color',val_cl);
    pos = pos-0.5;
    fprintf('(%.4f, %.4f): %.0f', sites_lons(s), sites_lats(s), val);

end

% Draw contour lines (curves connecting points of equal value) at the
% levels of [p95 p50 p05]
[C, h] = contour(X,Y,region_data,[p95 p50 p05],'k','LineWidth',0.5);
clabel(C, h, 'LabelSpacing', 1000, 'Color',val_cl);
%clabel(C, h, 'LabelSpacing', 1000, 'Color','r');

text(lon_min+0.2, lat_min+1.5, sprintf('95th Percentile: %.0f', p95), 'Color',val_cl);
text(lon_min+0.2, lat_min+1.0, sprintf('50th Percentile: %.0f', p50), 'Color',val_cl);
text(lon_min+0.2, lat_min+0.5, sprintf('5th Percentile: %.0f', p05), 'Color',val_cl);

if cluster
    % ---- Plot markers for centroids ----
    plot(c95(:,1), c95(:,2), 'ro', 'MarkerSize',8, 'LineWidth',2);
    plot(c50(:,1), c50(:,2), 'go', 'MarkerSize',8, 'LineWidth',2);
    plot(c05(:,1), c05(:,2), 'bo', 'MarkerSize',8, 'LineWidth',2);
    
    text(c95(:,1), c95(:,2), ' 95th', 'Color','r', 'FontSize',8);
    text(c50(:,1), c50(:,2), ' 50th', 'Color','g', 'FontSize',8);
    text(c05(:,1), c05(:,2), ' 5th',  'Color','b', 'FontSize',8);
end

%% Output file names
outfile_suffix = sprintf('%.1f_%.1f_%.1f_%.1f_%03d-%03d', ...
    lon_min, lon_max, lat_min, lat_max, start_doy, end_doy);

out_png = fullfile(data_dir, sprintf('%s_%s.png', out_prefix, outfile_suffix));
out_mat = fullfile(data_dir, sprintf('%s_%s.mat', out_prefix, outfile_suffix));

saveas(gcf, out_png);
fprintf('Saved map → %s\n', out_png);

if cluster
    save(out_mat, 'region_data', 'region_lon', 'region_lat', ...
        'p95', 'p50', 'p05', 'site_values', 'sites_lons', 'sites_lats', ...
        'p05_mask_centroids', 'p50_mask_centroids', ...
        'p95_mask_centroids', 'extent', 'start_date', 'end_date');
else
    save(out_mat, 'region_data', 'region_lon', 'region_lat', ...
        'p95', 'p50', 'p05', 'site_values', 'sites_lons', 'sites_lats', ...
        'extent', 'start_date', 'end_date');
end

fprintf('Saved regional data → %s\n\n', out_mat);

end

