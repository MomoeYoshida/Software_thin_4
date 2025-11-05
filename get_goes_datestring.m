function [datestring]=get_goes_datestring(year,day);

if(day<10)
   pad='00';
elseif(day<100)
   pad='0';
else
   pad='';
end

datestring=[num2str(year) '_' num2str_pad_zeros(day,3) ];
