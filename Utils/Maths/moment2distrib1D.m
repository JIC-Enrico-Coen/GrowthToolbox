function [mom2,centroid,total] = moment2distrib1D( xx, yy, centre )
%moment2distrib1D( xx, yy, centre )
%   XX is a vector of N positions on the X axis.
%   YY is a set of N values, each value being the amount of a quantity at
%   the corresponding element of XX.
%   CENTRE is a point, by default the centroid of the distribution.
%   Consider YY to define the distribution of concentration of a
%   substance over the range of XX, linearly interpolated, and zero
%   everywhere outside the range of XX.
%
%   Results:
%   MOM2 will be the second moment of that distribution about the centre.
%   CENTROID (if asked for) will be the centroid of the distribution.  If
%   CENTRE is omitted it will default to the centroid; in  that case MOM2
%   is the variance of the distribution.
%   TOTAL (if asked for) will be the total quantity of the distribution.
%
%   See also: meanpos.

    deltaxx = xx(2:end) - xx(1:(end-1))
    midxx = (xx(2:end) + xx(1:(end-1)))/2
    deltayy = (yy(2:end) - yy(1:(end-1)))
    midyy = (yy(2:end) + yy(1:(end-1)))/2
    
    weights = midyy .* deltaxx

    total = sum( weights );
    
    
%     centroidA = sum( (midxx+deltaxx/2) .* deltayy .* deltaxx )/total
%     centroidB = sum( midxx .* yy(1:(end-1)) .* deltaxx )/total
%     
%     centroid = centroidA + centroidB;
%     
%     mom2 = sum( (deltaxx/18 - (deltaxx.^2)*(4/9) + (midxx+deltaxx/2).^2) .* weights )/total;
%     return;





    xx2 = xx.^2;
    
    p2 = xx2(1:(end-1)) + xx(1:(end-1)).*xx(2:end) + xx2(2:end);
    xx2yy = xx2 .* yy;
    xx2yy_1 = xx2yy(2:end);
    xx2yy_0 = xx2yy(1:(end-1));
    
    if (nargin < 3) || (nargout > 1)
        centroid = sum( ...
            p2.*deltayy*(-1/6) ...
            + (xx2yy_1 - xx2yy_0)/2 ...
            )/total;
    end
    if nargin < 3
        centre = centroid;
    end
    midxx = midxx - centre;
    xx = xx - centre;
    
    xx3 = xx.^3;
    xx3_01 = xx3(2:end) + xx3(1:(end-1));
    xx_001_011 = (xx(1:(end-1)) .* xx(2:end)) .* midxx * 2;
    
    mom2_A = deltayy.*(xx3_01 + xx_001_011)/(-12);
    mom2_B = (yy(2:end).*xx3(2:end) - yy(1:(end-1)).*xx3(1:(end-1)))/3;
    
    mom2 = sum( mom2_A + mom2_B )/total;
end

