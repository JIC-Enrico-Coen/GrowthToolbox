function g = arealTensorGrowth( t )
%g = arealGrowth( t )
%   Compute the total growth rate of a two-dimensional growth tensor.
    g = t(1,1)*t(2,2) - t(1,2)^2;
end
