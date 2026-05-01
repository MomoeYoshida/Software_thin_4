

% interpolate estimates and error variances
% between fixed correlation lengths
%
% [x,p] = corr_interp( corrlenmap, len1, x1, p1, ..., lenm, xm, pm % ) 
% 
% len1 ... lenm are each scalars, the fixed correl. length for 
% field i % % x1 ... xm and p1 ... pm are 2D arrays, the estimates and 
% err. variances
%              If joint estimates are computed over multiple fields,
%              then corr_interp must be called once per field.
%

%
% version 1 - not based on least squares parameters
% just a sensible fit to constraints at fixed lengths
%

function [x,p] = corr_interp( cmap, varargin )

w = warning;
warning('off');


summap = zeros(size(varargin{1}));
curmap = summap;
x = summap;
p = summap;

for i=1:3:length(varargin),
  % Compute a weight based on how similar oi_corr_parm_001(1)(i.e., 8; fixed correlation length) is to cmap.
  % more similar >>> higher weight
  curmap = 1./((abs(log(cmap ./ varargin{i}))).^1.4);
  curmap(find(curmap>1e6)) = 1e6;

  % Apply the weight to anom and error.
  x = x + curmap .* varargin{i+1};
  p = p + curmap .* varargin{i+2};
  summap = summap + curmap;
end;

x = x ./ summap;
p = p ./ summap;

warning(w)
