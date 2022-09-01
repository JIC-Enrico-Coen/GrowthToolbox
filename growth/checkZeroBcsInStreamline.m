function [ok,maxbcerr,dbcerr] = checkZeroBcsInStreamline( s )
    TOLERANCEBC = 1e-4;
    TOLERANCEDBC = 1e-3;
    bcerrs = sum(s.barycoords,2)-1;
    [~,maxbcerri] = max(abs(bcerrs));
    maxbcerr = bcerrs(maxbcerri);
    dbcerr = sum(s.directionbc);
    badbc = abs(bcerrs) >= TOLERANCEBC;
    baddbc = abs(dbcerr) >= TOLERANCEDBC;
    ok = true;
    if any(badbc)
        if sum(badbc)==143
            xxxx = 1;
        end
        lastbcerrindex = find(badbc,1,'last');
        fprintf( '%s: streamline id %d has %d invalid bcs. Largest is [%f %f %f], error %f.\n', ...
            mfilename(), s.id, sum(badbc), s.barycoords(maxbcerri,:), maxbcerr );
        ok = false;
        xxxx = 1;
    end
    if baddbc
        fprintf( '%s: streamline id %d has invalid directionbc [%f %f %f], sum %f\n', ...
            mfilename(), s.id, s.directionbc, sum(s.directionbc) );
        ok = false;
        xxxx = 1;
    end
end

