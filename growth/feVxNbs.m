function nbcis = feVxNbs( m, cis )
%nbcis = feVxNbs( m, cis )
%   Find all FEs that share at least one vertex with any cell in cis,
%   excluding members of cis.
%   Compatible with volumetric meshes with a single type of FE.

    if usesNewFEs( m )
        vxmap = false( 1, size( m.FEnodes, 1 ) );
        vxmap( m.FEsets(1).fevxs( cis, : ) ) = true;
        okcells = any( vxmap( m.FEsets(1).fevxs ), 2 );
        okcells(cis) = false;
        nbcis = find(okcells);
    else
        vxs = unique(m.tricellvxs( cis, : ));
        nces = [ m.nodecelledges{vxs} ];
        nbcis = unique( nces(2,:) );
        if nbcis(1)==0
            nbcis = nbcis(2:end);
        end
    end
end

