function [out_array]=remove_overlap(in_array, scales);

sz=size(in_array);
xsize=sz(2);

x_wrap=scales(13);
if(x_wrap)
   x_overlap=abs(scales(12));
   out_array=in_array(:,(x_overlap+2):(xsize-(x_overlap+1)));
else
   out_array=in_array;
end
  
% Convert input year and day into datestring in style used in software package.
% ie.    yyyy_ddd where year is year, and ddd is day 
% eg.    '2004_032' is 2004, day 32, (1st February 2004).
%
%
% Input parameters:
%
%       Name               Type      Description
%    
%       year              Double    Julian year
%       day               Double    Day of year
%
% Output parameter:
%
%       Name               Type      Description
%    
%       datestring        Double    String representing date in style of 
%                                    yyyy_ddd where year is year, and ddd is day.
%      
%
 

% Convert year to string, padding with zeros of necessary to get string of width 4.

% Get Modifie Julian Date from year and day of year, and convert back
% to year and dayand day of year. This produces correct date when day 
% is not in range 1-365(6). For example to (2004,0) will give the
% date string '2003_365'.

