function [mjd]=date2mjd(year, day, month);

% Convert input year and day of year into modified julian day.
% ie.    yyddd where year is year-2000, and ddd is day 
% eg.    '04032' is 2004, day 32, (1st February 2004.
%
%
% Input parameters:
%
%       Name               Type      Description
%    
%       year              Double    Julian year
%       day               Double    Day of year (or day of month if month specified).
%       month             Double    Month of year  (optional)
%
% Output parameter:
%
%       Name               Type      Description
%    
%       datestring        Double    Modified Julian Day
%                                   (Days counted with Jan 1st, year 0 as 1.)
%      
%

if(nargin==2)
   jan_1st=datenum(year,1,1);
   mjd=jan_1st+day-1;
elseif(nargin==3)
   mjd=datenum(year, month, day);
end


