function [outarray]=smooth_analysis(inarray, smooth_factor);
warning off
land=find(inarray==-999);
inarray(land)=NaN;

land=find(isnan(inarray));
% smooths data array. 

a=inarray;
i=1-isnan(inarray);
an=a;
an(find(isnan(a)))=0;
as = conv2(an,ones(smooth_factor),'same')./conv2(i,ones(smooth_factor),'same');

if(length(land)>0)

   as(land)=NaN;
end

outarray=as;
