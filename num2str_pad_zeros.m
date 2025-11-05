function [numstring]=num2str_pad_zeros(i,w);

% Convert input number into string, and pad with zeros to produce string of
% total length w.
% ie.    if specified width is 3, 4 becomes '004', or 67 becomes '067'.
% eg.    '2004_032' is 2004, day 32, (1st February 2004).
%
%
% Input parameters:
%
%       Name             Type      Description
%    
%       i               Double   Number
%       w               Double   Width requird for output string.
%
% Output parameter:
%
%       Name               Type      Description
%    
%       numstring        string    String representing number with padded zeros.
%
 

% Convert year to string.

numstring=num2str(i);
n=length(numstring);

if(n>=w)
   return
else
   while (n<w)
      numstring=['0' numstring];
      n=length(numstring);
   end
end

