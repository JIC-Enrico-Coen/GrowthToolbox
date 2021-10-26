function [dirbc,dirglobal] = streamlineSegmentDirection( m, s, si )

    ci1 = s.vxcellindex(si);
    bc1 = s.barycoords(si,:);
    ci2 = s.vxcellindex(si+1);
    bc2 = s.barycoords(si+1,:);
    [ci, bc1, bc2] = referToSameTriangle( m, ci1, bc1, ci2, bc2 );
    if ~isempty(ci)
        dirbc = bc2-bc1;
        dirbc = dirbc/norm(dirbc);
        if any(isnan(dirbc))
            dirbc = [];
        end
    else
        dirbc = [];
    end
    dirglobal = s.globalcoords(si+1,:) - s.globalcoords(si,:);
    dirglobal = dirglobal/norm(dirglobal);
    if any(isnan(dirglobal))
        dirglobal = [0 0 0];
    end
end
