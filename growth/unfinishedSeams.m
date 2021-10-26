function vxs = unfinishedSeams( m )
%vxs = unfinishedSeams( m )
%   Find the ends of unfinished seams of m.  These are the vertexes lying
%   on exactly one seam and not on the edge of the mesh.

    seamEdgeEnds = sort( reshape( m.edgeends( m.seams, : ), [], 1 ) );
    seamvalency = countreps( seamEdgeEnds );
    edgeedges = m.edgecells(:,2)==0;
    edgevxs = unique( reshape( m.edgeends( edgeedges, : ), [], 1 ) );
    seamEnds = seamvalency( seamvalency(:,2)==1, 1 );
    
    numvxs = size( m.tricellvxs, 1 );
    x = false(numvxs);
    x(seamEnds) = 1;
    x(edgevxs) = 0;
    vxs = find(x);
end
