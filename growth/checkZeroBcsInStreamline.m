function ok = checkZeroBcsInStreamline( s )
    TOLERANCEBC = 1e-4;
    TOLERANCEDBC = 1e-3;
    ok = all( abs(sum(s.barycoords,2)-1) < TOLERANCEBC ) && (abs(sum(s.directionbc)) < TOLERANCEDBC);
    if ~ok
        fprintf( '%s: invalid bcs found in streamline id %d.\n', mfilename(), s.id );
        xxxx = 1;
    end
end

