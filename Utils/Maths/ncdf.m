function n = ncdf( x, mean, sd )
    if nargin < 1
        mean = 0;
    end
    if nargin < 2
        sd = 1;
    end
    n = 0.5*erfc( -((x/sd)-mean)/sqrt(2) );
end
