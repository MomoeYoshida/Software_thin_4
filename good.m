function [outarray]=good(array, badval);


outarray=array(find(~isnan(array)));

if(nargin==2)
   outarray=outarray(find(outarray ~= badval));
end
