function bc = trimbc( bc, tolerance )
    if nargin < 2
        tolerance = 1e-8;
    end
    bc( bc<tolerance ) = 0;
    bc( bc>1-tolerance ) = 1;
end
