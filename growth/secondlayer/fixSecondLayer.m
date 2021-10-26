function m = fixSecondLayer( m, biovxsToFix, hint )
%m = fixSecondLayer( m, biovxs, hint )
%   biovxs is a list of biological vertexes lying in cells of m that have
%   just moved.  This function recomputes their coordinates, using hint as
%   a list of places to look in first.

    if ~hasNonemptySecondLayer( m )
        return;
    end
    for i=1:length(biovxsToFix)
        pi = biovxsToFix(i);
        pti = m.secondlayer.cell3dcoords(pi,:);
        [ ci, bc ] = findFE( m, pti, 'hint', hint );
        bc = normaliseBaryCoords( bc );
        m.secondlayer.vxFEMcell(pi) = ci;
        m.secondlayer.vxBaryCoords(pi,:) = bc;
    end
end
