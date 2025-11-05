function [year, day, month]= mjd2date(mjd);

% Convert input modified julian day to year and day and optionally month.
% If two output arguments are specified these are assumed to be year and 
% day of year. 
% If three output arguments are specified these are assumed to be year, day of 
% month, and month. 
%  eg.   Modified Julian Day 731981 is 4th Feb 2004
%   [year, day]        = mjd2date(731981);   returns year=2004, day of year=35
% & [year, day, month] = mjd2date(731981);   returns year=2004, day of month=4,
%                                            & month=2.
%
%
% Input parameter:
%
%       Name               Type      Description
%    
%       MJD                Double    Modified Julian Day
%                                   (Days counted with Jan 1st, year 0 as 1.)
%      
% Ouput parameters:
%
%       Name               Type      Description
%    
%       year              Double    Julian year
%       day               Double    Day of year (or day of month if month specified).
%       month             Double    Month of year  (optional)


year=str2num(datestr(mjd,10));


if(nargout==2)
   jan_1st=datenum(year,1,1);
   day=mjd-jan_1st+1;
elseif(nargout==3)
   month=str2num(datestr(mjd,5));
   day=str2num(datestr(mjd,7));
end


