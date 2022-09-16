function vxdeficit = meshcurvature( m )
%vxdeficit = meshcurvature( m )
%
% THIS PROCEDURE IS NEVER USED. It is likely experimental and incomplete.
%
%   Calculate a measure of the curvature of a foliate mesh. At each
%   interior vertex we find the difference between the sum of angles around
%   the vertex and 2pi. For border vertexes we compare with the angle
%   between the two border edges.
%
%   For foliate meshes only (but could be extended to measure the curvature
%   of the surface of a 3d mesh, if wanted).

% Do we need to scale this by the area of the triangles? What is the total
% curvature for a sphere? Gaussian curvature at each point is 1/r^2.
% Multiplied by area 4pi r^2 gives 4pi. This should be the same for every
% sphere-like surface. Can we ensure that the total curvature for a polygon
% mesh also comes out to 4pi?  For a cube of semidiameter r we have an area
% of 24r^2. Divided among 8 vertexes that is 3pi r^2 per vertex. The angular
% deficit at each vertex is pi/2. So it seems we have to allocate an area
% of 6r^2 to each vertex.  But the area divided by the number of vertexes
% is only 3 r^2. And suppose we divide the cube more finely? We get a large
% number of vertexes with a deficit of zero, and still 8 with a deficit of
% pi/4.

% Cube: total angular deficit is 4pi.
% Tetrahedron: also 4pi.
% Octahedron: also 4pi.
% Dodecahedron: 20 vertexes * (2pi - 3*(3/5)pi) = pi(40 - 36) = 4pi.
% Isocahedron: also 4pi.
% And a few other regular solids are the same.
% This looks like a universal rule.

% We probably want a measure that is independent of scale. Angular deficit
% seems to fit.

% 1. Calculate lengths and squared lengths of all edges.
    edgelensq = sum( (m.nodes( m.edgeends(:,1), : ) - m.nodes( m.edgeends(:,2), : )).^2, 2 );
    edgelen = sqrt( edgelensq );

% 2. Put them together into triples by triangles.
    trilensq = edgelensq( m.celledges );
    trilen = edgelen( m.celledges );
    
% 3. Calculate by the cos rule for two of the angles of each triangle.

    numerators = trilensq*[-1 1;1 -1;1 1];
    denominators = 2 * [ trilen(:,2) .* trilen(:,3), trilen(:,1) .* trilen(:,3) ];
    cosines = numerators ./ denominators;
    angles = acos(cosines);
    
% 4. Get the third angle by subtracting the others from pi.
    angles = [ angles, pi - sum(angles,2) ];

% 5. Convert to per-vertex sums of angles.
    vxangles = [ reshape( double(m.tricellvxs'), [], 1 ), reshape( angles', [], 1 ) ];
    vxangles = sortrows( vxangles );
    % vxangles lists for each vertex each of its angles for the triangles
    % it belongs to.
    [starts,ends, vxs] = runends( vxangles(:,1) );
    % vxs should be identical to 1:getNumberOfVertexes(m)
    numvxs = getNumberOfVertexes(m);
    vxtotalangle = zeros( numvxs, 1 );
    for i=1:numvxs
        vxtotalangle(i) = sum( vxangles(starts(i):ends(i),2) );
    end
    
% 6. Find the border edges and vertexes.
    borderedgemap = m.edgecells(:,2)==0;
    bordervxlist = unique( m.edgeends(borderedgemap,:) );
    bordervxmap = false( numvxs, 1 );
    bordervxmap( bordervxlist ) = true;
    vxdeficit = zeros( numvxs, 1 );

% 7. For interior vertexes, subtract the angle sum from 2pi.
    vxdeficit = 2*pi - vxtotalangle;
    vxdeficit( bordervxlist ) = 0;
    
%     return;
    
    % For the border edges there is no good way of defining curvature. We
    % take the average of the neighbouring non-border vertexes.
    for bvi=1:length(bordervxlist)
        vi = bordervxlist(bvi);
        nce = m.nodecelledges{vi};
        ve = nce(1,:);
        nbs = unique( m.edgeends(ve,:) );
        nbs(bordervxmap(nbs)) = [];
        nbdeficit = mean( vxdeficit( nbs ) );
        if isnan(nbdeficit)
            nbdeficit = 0;
        end
        vxdeficit(vi) = nbdeficit;
    end
    
    return;
    
% BORDER EDGES NOT WORKING YET.
% 8. For border vertexes, subtract the angle sum from the angle between the
% border edges.
    % For each border vertex we must find the border edges it belongs to.
    edgedata = [ double(m.edgeends(borderedgemap,:)), edgelensq(borderedgemap), edgelen(borderedgemap), find(borderedgemap) ];
    edgedata = [ edgedata; edgedata(:,[2 1 3 4 5]) ];
    edgedata = sortrows(edgedata);
    % edgedata now contains two rows for each vertex. Vertex n is
    % represented by rows 2n-1 and 2n, one row for each of the two border
    % edges it belongs to.  The four elements in each row are n, the other
    % vertex of that edge, and the squared and unsquared length of that
    % edge.
    
    % Extract the edge length data.
    edgelensq1 = edgedata(1:2:end,3);
    edgelensq2 = edgedata(2:2:end,3);
    edgelen1 = edgedata(1:2:end,4);
    edgelen2 = edgedata(2:2:end,4);
    
    % Calculate the squared length of the third edge.
    edgelensq3 = sum( (m.nodes(edgedata(1:2:end,2),:) - m.nodes(edgedata(2:2:end,2),:)).^2, 2 );
    
    % Use the cosine rule to find the angle.
    % The cosine rule will always return a value in the range 0..pi, but a
    % concave vertex should return the other solution, on the range
    % pi..2pi.  We detect concave vertexes by using the sign of the triple
    % product of the two edge vectors and the vertex normal, together with
    % the sense of the edge vectors.
    bordercells = m.edgecells( edgedata(1:2:end,5), 1 );
    bordercellvxs = m.tricellvxs( bordercells, : );
    sense = vxpairsense( edgedata(1:2:end,[1 2]), bordercellvxs );
    % Take the triple product of the first edge, the second edge, and the
    % normal.
    vxs = edgedata(1:2:end,1);
    pvxs = vxs*2;
    edgevec1 = m.nodes(edgedata(1:2:end,2),:) - m.nodes(vxs,:);
    edgevec2 = m.nodes(edgedata(2:2:end,2),:) - m.nodes(vxs,:);
    normalvec = m.prismnodes( pvxs, : ) - m.prismnodes( pvxs-1, : );
    concave = (double(sense)*2 - 1) .* sign( dot( edgevec1, cross( edgevec2, normalvec, 2 ), 2 ) ) < 0;
    
    % Cosine rule
    thirdcosangle = (edgelensq1 + edgelensq2 - edgelensq3)./(2*(edgelen1 .* edgelen2));
    thirdangle = acos( thirdcosangle );
    
    % Correction for concave vertexes.
    thirdangle(concave) = 2*pi - thirdangle(concave);
    
    % Calculate the deficit.
    vxdeficit( bordervxlist ) = thirdangle - vxtotalangle( bordervxlist );
end
