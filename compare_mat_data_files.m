function compare_mat_data_files(file1, file2);
% =========================================================================
% Compare two .mat files (two different versions) variable, pixel by pixel,
% to check whether every pixel value in each variable is identical.
%
% INPUTS:
%   file1 - path to the first .mat file (e.g., your generated data)
%   file2 - path to the second .mat file (e.g., advisor's data)
% 
% EXAMPLE:
%   compare_mat_files('/Users/momotalo/Documents/momoe/macOS_MacBookPro/blended_home
%                       /Input_ssts/mio_night_2025_011.mat', 'advisor_version.mat',
%                     '/Users/momotalo/Documents/ANDY/for_JCU/mio_night_2025_011.mat');
%
% Author: Momoe Yoshida
% Date: Tue 21 Oct 2025
% TNT: doesn't really work the way that helps me
% =========================================================================

    fprintf('Loading files...\n');
    data1 = load(file1);
    data2 = load(file2);
    
    vars1 = fieldnames(data1);
    vars2 = fieldnames(data2);
    commonVars = intersect(vars1, vars2);
    fprintf('\nComparing common variables between files:\n');
    disp(commonVars);
    
    % --------------------------------------------------------------------
    % Compare each variable.
    % --------------------------------------------------------------------
    for v = 1:length(commonVars)
        varname = commonVars{v};
        fprintf('\n==============================\n');
        fprintf('Variable: %s\n', varname);
        fprintf('==============================\n');
    
        a = data1.(varname);
        b = data2.(varname);
    
        % Check for size mismatch.
        if ~isequal(size(a), size(b))
            fprintf('⚠️  Different sizes: %s vs %s\n', mat2str(size(a)), mat2str(size(b)));
            continue;
        end
    
        % Compute differences.
        diffMask = a ~= b;
    
        numDiff = nnz(diffMask);
        total = numel(a);
    
        if numDiff == 0
            fprintf('✅ All pixels identical.\n');
        else
            fprintf('⚠️  %d pixels differ (%.6f%% of total)\n', numDiff, 100*numDiff/total);
    
            % Show first few differing indices.
            [row, col] = find(diffMask);
            fprintf('First few differing (row, col):\n');
            disp([row(1:min(10,end)), col(1:min(10,end))]);
    
            % Show example differences.
            diffValues = a(diffMask) - b(diffMask);
            fprintf('Example value differences (file1 - file2):\n');
            disp(diffValues(1:min(5,end)));
    
            % Visualizs.
            figure;
            imagesc(diffMask);
            axis equal tight;
            colorbar;
            title(sprintf('Pixels different for %s', varname), 'Interpreter', 'none');
        end
    end
    
    fprintf('\nComparison complete.\n');

end