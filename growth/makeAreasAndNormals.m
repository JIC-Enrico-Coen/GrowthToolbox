function m = makeAreasAndNormals( m, cells )
%m = makeAreasAndNormals( m, cells )
%   Compute the normal vector and area of the given finite elements, by
%   default all of them.  We do these
%   together, since this is faster than computing them separately.

    full3d = usesNewFEs( m );
    if nargin < 2
        if full3d
            [m.cellareas,m.unitcellnormals] = ...
                triangleareas( m.FEnodes, m.FEsets(1).fevxs );
        else
            [m.cellareas,m.unitcellnormals] = ...
                triangleareas( m.nodes, m.tricellvxs );
        end
    else
        if full3d
            [m.cellareas(cells),m.unitcellnormals(cells,:)] = ...
                triangleareas( m.FEnodes, m.FEsets(1).fevxs(cells,:) );
        else
            [m.cellareas(cells),m.unitcellnormals(cells,:)] = ...
                triangleareas( m.nodes, m.tricellvxs(cells,:) );
        end
    end

    m.globalDynamicProps.currentArea = sum( m.cellareas );
    m.globalDynamicProps.cellscale = sqrt( m.globalDynamicProps.currentArea / length(m.cellareas) );
end
