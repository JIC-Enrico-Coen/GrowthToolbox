function c1 = saturate( v, c )
%c1 = saturate( v, c )
%   c is an RGB colour.  v is a vector of N reals.  The results is an N*3
%   array of N colours, being copies of c saturated by each element of v.
%   Where v is 0, the colour is [1,1,1] (white), and where v is 1, the
%   colour is c, with linear interpolation between.  There is no check that
%   v or c are within the range 0..1

    c1 = v(:)*c + (1-v(:))*[1 1 1];
end
