function [correlation_map]=get_correlation_map(obs_map, lmin, lmax);
% Function to create correlation map from observation map.

use1=ones(lmin);
use2=ones(lmax);
c1=conv2(obs_map,use1,'same');
c2=conv2(obs_map,use2,'same');
n1=lmin*lmin;
n2=lmax*lmax;

alpha=2/pi*atan2((c2/n2),(1-c1/n1));

correlation_map=lmax*(1-alpha)+alpha*lmin;
  
