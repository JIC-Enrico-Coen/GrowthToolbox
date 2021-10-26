function cis = connectedComponent( m, ci )
%cis = connectedComponent( m, ci )
%   ci is the index of a finite element of m.  Find the set of all elements in the
%   strongly connected component of ci, i.e. those reachable from ci
%   by traversing edges.

    cis = ci;
    newCells = true(1,size(m.tricellvxs,1));
    recentCells = cis;
    newCells(recentCells) = false;
    while ~isempty(recentCells)
        bc = borderingCells(m,recentCells);
        bc = bc( newCells(bc) );
        recentCells = reshape( unique( bc ), [], 1 );
        cis = [ cis; recentCells ];
        newCells(recentCells) = false;
    end
end

