function h = dimagesc(varargin)
%IMAGESC Scale data and display as image.
%   IMAGESC(...) is the same as IMAGE(...) except the data is scaled
%   to use the full colormap.
%   
%   IMAGESC(...,CLIM) where CLIM = [CLOW CHIGH] can specify the
%   scaling.
%
%   See also IMAGE, COLORBAR, IMREAD, IMWRITE.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2009/02/11 18:10:46 $

clim = [];
if nargin == 0,
  hh = image('CDataMapping','scaled');
elseif nargin == 1,
 hh = image(denan(varargin{1}),'CDataMapping','scaled');
 clim=[-2,35];

elseif nargin > 1,

  % Determine if last input is clim
  if isequal(size(varargin{end}),[1 2])
    for i=length(varargin):-1:1,
      str(i) = isstr(varargin{i});
    end
    str = find(str);
    if isempty(str) | (rem(length(varargin)-min(str),2)==0), 
       clim = varargin{end};
       varargin(end) = []; % Remove last cell
    else
       clim = [-2.1,35];
    end
  else
     clim = [-2,35];
  end
  hh = image(denan(varargin{:}),'CDataMapping','scaled');
end

if ~isempty(clim),
  set(gca,'CLim',clim)
elseif ~ishold,
  set(gca,'CLimMode','auto')
end

if nargout > 0
    h = hh;
end

%set(gca,'color','k')
axis xy
axis image 
load jojetm
colormap(jojetm)
colorbar
