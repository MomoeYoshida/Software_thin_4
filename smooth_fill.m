function [outarray, nunfill]=smooth_fill(inarray, landmask, smooth_factor);

% smooths and fills data array. 

a=inarray;
i=1-isnan(inarray);
an=a;
land=find(landmask<1);
an(find(isnan(a)))=0;
as = conv2(an,ones(smooth_factor),'same')./conv2(i,ones(smooth_factor),'same');
as(land)=NaN;
outarray=as;

nunfill=length(find(isnan(outarray)& landmask>0))
