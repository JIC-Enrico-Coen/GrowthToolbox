function vols = feVolumes( m, fes )
%vols = feVolumes( m, fes )
%   Calculate the volumes (for a tetrahedral mesh) or the areas (for a
%   triangular mesh) of the given set of finite elements, by default all of
%   them.

    if nargin < 2
        fes = 1:getNumberOfFEs(m);
    end
    if usesNewFEs( m )
        vols = tetravolume( m.FEnodes, m.FEsets(1).fevxs(fes,:) );
    else
        vols = triangleareas( m.nodes, m.tricellvxs(fes,:) );
    end
end
