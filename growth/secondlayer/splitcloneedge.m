function [ vi, bc ] = splitcloneedge( mesh, ei, a, b )
%[ vi, bc ] = splitcloneedge( mesh, ei, a, b )
%   Given a second layer edge ei that is to be split, return the FEM cell
%   and barycentric coordinates of the new point.

    vi = 0;
    bc = [ 0 0 0 ];

    if nargin < 3, a = 0.5; end
    if nargin < 4, b = 1-a; end

%    fprintf( 1, 'splitcloneedge\n' );

    edgedata = mesh.secondlayer.edges( ei, : );
    vi1 = edgedata(1);
    vi2 = edgedata(2);
    femCell1 = mesh.secondlayer.vxFEMcell( vi1 );
    femCell2 = mesh.secondlayer.vxFEMcell( vi2 );
    bc1 = mesh.secondlayer.vxBaryCoords( vi1, : );
    bc2 = mesh.secondlayer.vxBaryCoords( vi2, : );
    
    if femCell1 == femCell2
        % Both ends of the edge are in the same cell.
        % The midpoint must be in the same cell, and its barycentric
        % coordinates are the midpoint of those of the ends.
        vi = femCell1;
        bc = a*bc1 + b*bc2;
    %    fprintf( 1, 'splitcloneedge simple case, cell %d\n', femCell1 );
        return;
    end
    
    % Get the 3D coords of the endpoints.
    coords3d1 = mesh.secondlayer.cell3dcoords( vi1, : );
    coords3d2 = mesh.secondlayer.cell3dcoords( vi2, : );
    
    [ eci1, eci2 ] = sharedEdge( mesh, femCell1, femCell2 );
    if eci1 ~= 0
        % The ends of the edge are in neighbouring FEM cells which share an
        % edge.
        
        ei = mesh.celledges( femCell1, eci1 );

        % Get the FEM 
        femVx1 = mesh.edgeends( ei, 1 );
        femVx2 = mesh.edgeends( ei, 2 );
        
        % Get the 3D coords of the endpoints of the shared edge.
        femVx1coords = mesh.nodes( femVx1, : );
        femVx2coords = mesh.nodes( femVx2, : );
        
        v = pathViaEdge( coords3d1, coords3d2, femVx1coords, femVx2coords );
        vbc2 = baryCoords2( femVx1coords, femVx2coords, v );
        db = norm( coords3d1 - v );
        da = norm( coords3d2 - v );
        dab = da+db;  da = da/dab;  db = db/dab;
        bce = zeros(1,3);
        if da <= a
            % The intersection is closer to the second point than the
            % first.  Therefore choose the splitting point within the first
            % cell.
            
            % Find the barycentric coordinates of v in femCell1.  They must
            % be the elements of vbc2, and zero, in some order.
            vci23 = othersOf3( eci1 );
            bce( vci23 ) = vbc2;
            
            % Now average bc1 and bce to obtain the point half way between
            % vi1 and vi2.
            b1 = b/db;
            a1 = 1-b1;
            bc = a1 * bc1 + b1 * bce;
            vi = femCell1;
        else
            vci23 = othersOf3( eci2 );
            bce( vci23 ) = vbc2;
            b1 = a/da;
            a1 = 1-b1;
            bc = a1 * bc2 + b1 * bce;
            vi = femCell2;
        end
        if 0
            fprintf( 1, 'splitcloneedge case2, cells %d %d, bce [%.3f %.3f %.3f], result cell %d [%.3f %.3f %.3f]\n', ...
                femCell1, femCell2, bce, vi, bc );
        end
        return;
    end

    % If the planes of the cells intersect in a line, find
    % the shortest path via that line, then intersect it with the edges of
    % the cells.  Then consider the path composed of three sections: from
    % each vertex to an edge of its cell, and the straight line between the
    % edge points.  Calculate the distances of all three, then decide which
    % of the three the new point should lie in.  If in either of the cells,
    % calculate its bcs in that cell, otherwise choose the closer edge
    % point.
    
    % If the planes of the cells are parallel, project the direct line onto
    % each cell and intersect with its edges.  Then proceed as the previous
    % case.
end





    
