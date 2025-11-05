function [outarray] = denan(inarray);
badval=-999;
outarray=inarray;
bad=find(isnan(inarray)==1);
outarray(bad)=badval;
