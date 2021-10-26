function m = updateFEpolarisation( m, w, alph, generalV )
%m = updateFEpolarisation( m, w, normalise, alph, generalV )
%   Replace each polarisation vector by a weighted average of it, its
%   neighbours, and GENERALV.  w is the amount of neighbour influence,
%   and alph the amount of general influence, both in the range 0..1.

    if ~isfield( m, 'FEpolarisation' ), return; end

    newpolarisation = zeros( size( m.FEpolarisation ) );
    for ci=1:size(m.tricellvxs,1)
        if ~m.FEpolfixed(ci)
            cis = cellneighbours( m, ci );
            cis = cis(cis ~= 0);
            numnbs = length(cis);
            if ~isempty(cis)
                vectors = [ generalV; m.FEpolarisation([ci,cis],:) ];
                w1 = w*numnbs/3;
                weights = [ alph, (1-alph)*[ 1-w1, (w1/numnbs)*ones(1,numnbs) ] ];
                newpol = averageDirection( ...
                    vectors, weights, m.unitcellnormals(ci,:) );
                if any(newpol)
                    newpolarisation(ci,:) = newpol;
                else
                    newpolarisation(ci,:) = randperp( m.unitcellnormals( ci, : ) );
                end
            end
        end
    end
    m.FEpolarisation = newpolarisation;
end

