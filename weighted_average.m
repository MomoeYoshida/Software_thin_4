function [outarray]= weighted_average(array1, array2, wt1, wt2, bad_val);
warning off
outarray=NaN*ones(size(array1));
kount=zeros(size(array1));

vals1=find(~isnan(array1) & ~(array1==bad_val));
vals2=find(~isnan(array2) & ~(array2==bad_val));


outarray(vals1)=wt1*array1(vals1);
kount(vals1)=kount(vals1)+wt1;

outarray(vals2)=outarray(vals2)+wt2*array2(vals2);
kount(vals2)=kount(vals2)+wt2;

outarray=outarray./kount;
