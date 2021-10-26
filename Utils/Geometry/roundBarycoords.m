function bc = roundBarycoords( bc, tolerance )
    if nargin < 2
        tolerance = 1e-4;
    end
    
    bc(bc < tolerance) = 0;
    bc = bc/sum(bc);
    bc(1-bc < tolerance) = 1;
    if any(bc==1)
        bc(bc ~= 1) = 0;
    end
end