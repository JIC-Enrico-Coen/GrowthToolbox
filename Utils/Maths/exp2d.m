function e = exp2d( sd, dx, stds )
%e = exp2d( sd, dx, stds )
%   Generate a circular Gaussian distribution.  The standard deviation in
%   each direction is sd, and the increment of distance is dx. The
%   distribution is calculated out to STDS standard deviations (by default
%   4).
%
%   The result is an N*N array, where N = 2*rad+1 and rad is a integer
%   about stds*sd/dx. N will always be at least 3.
%
%   The resulting distribution is guaranteed to have a standard deviation
%   close to sd.  When sd*stds is no more than three times dx, the
%   coarseness of the grid implies that this cannot be achieved by simply
%   computing the value of exp(-r^2/(2*sd^2)) at the grid points.
%   Therefore, when rad <= 3, we compute a binomial filter with exactly the
%   required standard deviation.  The Gaussian formula would give a filter
%   with a standard deviation substantially lower than the specified value.

    if nargin < 3
        stds = 4;
    end
    rad = max( round(sd*stds/dx), 1 );
    len = rad+rad+1;
    xsq = ((-rad:rad)*dx).^2;
    switch rad
        case 1
            eps = ((sd/dx)^2);
            e1 = [ eps/2, 1-eps, eps/2 ];
            e = repmat(e1',1,len) .* repmat(e1,len,1);
        case 2
            eps = ((sd/dx)^2)/2;
            e1 = [ eps^2/4, eps*(1-eps), 1-2*eps+1.5*eps^2 ];
            e1 = e1([1 2 3 2 1]);
            e = repmat(e1',1,len) .* repmat(e1,len,1);
        case 3
            eps = ((sd/dx)^2)/3;
            e1 = [ eps/2, 1-eps ];
            e11 = e1'*e1;
            e2 = [ e11(1,1), 2*e11(1,2), 2*e11(1,1)+e11(2,2) ];
            e12 = e1'*e2;
            e3 = [ e12(1,1), e12(2,1)+e12(1,2), e12(1,1)+e12(2,2)+e12(1,3), 2*e12(1,2)+e12(2,3) ];
            e3 = e3( [1 2 3 4 3 2 1] );
            e = repmat(e3',1,len) .* repmat(e3,len,1);
        otherwise
            e = exp( -(repmat(xsq',1,len) + repmat(xsq,len,1))/(2*sd*sd) );
            e = e/sum(e(:));
    end
    
%     sd1 = sqrt( sum( e(rad+1,:).*xsq )/sum( e(rad+1,:) ) )
%     err = abs(sd-sd1)/sd
end
