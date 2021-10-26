function [ eci1, eci2 ] = sharedEdge( mesh, ci1, ci2 )
%[ eci1, eci2 ] = sharedEdge( mesh, ci1, ci2 )
%   Determine the cell-edge indexes of the edge common to the two cells.
%   Zero if no common edge.
    eci2 = find( mesh.celledges( ci2, : )==mesh.celledges( ci1, 1 ), 1 );
    if eci2, eci1 = 1; return; end
    eci2 = find( mesh.celledges( ci2, : )==mesh.celledges( ci1, 2 ), 1 );
    if eci2, eci1 = 2; return; end
    eci2 = find( mesh.celledges( ci2, : )==mesh.celledges( ci1, 3 ), 1 );
    if eci2, eci1 = 3; return; end
    eci1 = 0;
end
