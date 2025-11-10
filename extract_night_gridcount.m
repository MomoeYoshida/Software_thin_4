function extract_night_gridcount(year, jday);
    
    
    %
    % Function to sum/accumulate night gridcount from multiple data sources.
    % Save the output file as 'leo/geo/sum_night_gridcount_YYYY_JJJ.mat'
    % Refer to the "average_all_inputs_gridcount.m" 
    %
    % MY 25Mar25 - First Creation
    % MY 1Apr25  - Edit: add texts (i.e., print) to display what each step
    % does
    
    
    
    % Declare as global variables, allowing access to their contents throughout the script.
    global file_info par_info;
    
    init_file_info;  % likely define 'file_info'
    init_par_info;  % likely define 'par_info'
    
    % Define spatial resolution (from global variables)
    spatial_resolution = par_info.spatial_resolution;  % =[3600,7200], which are 
    % equal to the number of latitude values and that of longitudes

    dir_input_ssts = file_info.dir_input_ssts;
    dir_analysis = file_info.dir_analysis;
    name_dataset = 'name_dataset_';
    obs_nums = [2, 3, 4, 5, 6, 7, 8, 9, 10]; % nighttime-only
    
    % Initialize an array for total gridcount accumulation - same shape as the
    % 'spatial_resolution' for leo, geo and sum.
    num_leo = zeros(spatial_resolution);
    num_geo = zeros(spatial_resolution);
    num_sum = zeros(spatial_resolution);
    
    % Generate date string in the format 'YYYY_JJJ'
    date_string = get_datestring(year, jday);  % call the function get_datestring.m
    
    % Loop through each satellite nighttime data source.
    % e.g., viirs, METOPB, METOPC and jpss for leo
    for i=[obs_nums]  % ** The dataset numbers for input data sources 
                      % -> See the line 22-23 in test.m **
    
       % Convert 'i' into a 3-digit string (e.g., 2 into 002).
       data_string=sprintf('%03d', i);
    
       % Load up observational data
    
       obs_file=['file_info.' name_dataset data_string];  % e.g., file_info.name_dataset_002 = 'viirs_night_c0_';
       eval(['obs_file=' obs_file ';'])
       
    %   full_obs_filename=[ dir_input_ssts obs_file date_string '.mat'];
       full_obs_filename=[ dir_input_ssts obs_file date_string '.mat'];  % e.g., './viirs_night_c0_2025_001.mat'

       fprintf('********* Reading the file: %s\n ... *********', full_obs_filename);

       % Load 'sst' and 'gridcount' variables from the file.
       eval(['load ' full_obs_filename ' sst gridcount']);  % the 'eval' command is used to dynamically generate the load command
    
       % Identify grid cells (i.e., lat-lon pairs) with 'gridcount>0'.
       good_ssts=find(gridcount>0);  % indices
    
       % Accumulate/Add gridcount from the current (satellite) data source/file
       % to 'num_all' - the arrays of the shape (3600,7200).
       if ismember(i, [2,3,4,10])
        num_leo(good_ssts) = num_leo(good_ssts) + double(gridcount(good_ssts));
        % ** double(X) converts the values in X to double precision, usually 64 bits in computer memory **
       elseif ismember(i, [5,6,7,8,9])
        num_geo(good_ssts) = num_geo(good_ssts) + double(gridcount(good_ssts));
       else
        warning('Unknown obs_num %d — skipping.', i);
       end

       % % Produce the histogram.
       % min_num_all = min(num_all(:), [], 'omitnan'); % ignoring NaNs
       % max_num_all = max(num_all(:), [], 'omitnan');
       % fprintf("The minimum num_all value is %d.\n", min_num_all);
       % fprintf("The maximum num_all value is %d.\n", max_num_all);
       % 
       % step = 10;
       % bins_num_all = min_num_all:step:(max_num_all + step);
       % [counts, edges] = histcounts(num_all(:), bins_num_all);
       % % Display histogram results
       % disp(table(edges(1:end-1)', counts', 'VariableNames', {'BinEdges', 'Counts'}));
    
       % *** This function returns 'leo/geo_night_gridcount'. ***
    end
    num_sum = num_leo + num_geo;

    % Save all outputs
    output_leo = fullfile(dir_analysis, sprintf('leo_night_gridcount_%d_%03d.mat', year, jday));
    output_geo = fullfile(dir_analysis, sprintf('geo_night_gridcount_%d_%03d.mat', year, jday));
    output_sum = fullfile(dir_analysis, sprintf('sum_night_gridcount_%d_%03d.mat', year, jday));
    
    save(output_leo, 'num_leo');
    save(output_geo, 'num_geo');
    save(output_sum, 'num_sum');
    
    fprintf('✅ Saved:\n  %s\n  %s\n  %s\n', output_leo, output_geo, output_sum);

end
