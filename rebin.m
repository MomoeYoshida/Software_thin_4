function [adata] = ...
                           rebin(pdata,factor,method);

% Routine to do integer rebin


dim_in=size(pdata);
xsize=dim_in(2);
ysize=dim_in(1);


p_delta=factor;
a_delta=1;

[px,py]=meshgrid(1:xsize,1:ysize);

xdelt=(xsize-1)/(xsize*factor-1);
ydelt=(ysize-1)/(ysize*factor-1);
                 
[ax,ay]=meshgrid(1:xdelt:xsize,1:ydelt:ysize);

adata     = interp2(px,py,pdata,ax,ay,method);
