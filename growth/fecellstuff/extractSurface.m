function [s,embedding] = extractSurface( m, oriented )
%s = extractSurface( m, oriented )
%   m is a volumetric mesh of tetrahedra.  The result is a triangular mesh
%   of the surface of m, together with an indexing mapping its vertexes,
%   edges, and faces back to those of m, and a mapping of its faces to the
%   tetrahedra of m.  [2017 Feb 08: Actually, not all of this information
%   is yet computed and returned.]
%
%   If oriented is true, the surface is assured to have a consistent
%   orientation. If false, it is not: the vertexes of each face are listed
%   in arbitrary cyclic order. The default is true.
%
%   The fields of s are:
%
%       nodes:  V*3.  The coordinates of all the vertexes.
%       tricellvxs:  N*3. The triples of vertex indexes for each triangle.
%           These have consistent orientation, i.e. for each edge shared by
%           two faces, its vertexes are listed in opposite orders in the
%           corresponding two rows of tricellvxs.
%       edgeends:  E*2.  The pairs of vertex indexes that are the ends of
%           each edge, in arbitrary order.
%       edgecells:  E*2.  For each edge, the indexes of the triangles on
%           either side.  If as edge has a triangle on only one side, the
%           second index is zero.
%       celledges:  N*3.  For each triangle, the indexes of its three
%           edges. The ordering is consistent with tricellvxs:
%           celledges(i,j) is the edge opposite to the vertex
%           tricellvxs(i,j).

    if nargin < 2
        oriented = true;
    end
    surfacefacemap = m.FEconnectivity.faceloctype==1;
    surfaceedgeindexes = unique( m.FEconnectivity.faceedges( surfacefacemap, : ) );
    surfacevertexindexes = unique( m.FEconnectivity.faces( surfacefacemap, : ) );
    
    numVolFaces = length( m.FEconnectivity.faceloctype );
    numSurfaceFaces = sum( surfacefacemap );
    numVolEdges = size( m.FEconnectivity.edgeends, 1 );
    numSurfaceEdges = length( surfaceedgeindexes );
    numVolVertexes = size( m.FEnodes, 1 );
    numSurfaceVertexes = length( surfacevertexindexes );
        
    embedding.faceVolToSurfaceIndex = zeros( numVolFaces, 1 );
    embedding.faceVolToSurfaceIndex(surfacefacemap) = 1:numSurfaceFaces;
    embedding.faceSurfaceToVolIndex = find(surfacefacemap);
    embedding.edgeVolToSurfaceIndex = zeros( numVolEdges, 1 );
    embedding.edgeVolToSurfaceIndex(surfaceedgeindexes) = 1:numSurfaceEdges;
    embedding.edgeSurfaceToVolIndex = surfaceedgeindexes;
    embedding.vertexVolToSurfaceIndex = zeros( numVolVertexes, 1 );
    embedding.vertexVolToSurfaceIndex(surfacevertexindexes) = 1:numSurfaceVertexes;
    embedding.vertexSurfaceToVolIndex = surfacevertexindexes;
    
    
    
    % Want fields embedding.surfaceFaceToVolFE (easy) and
    % embedding.surfaceFaceToVolFEFace (harder).
%     m.FEconnectivity.
    
    s.tricellvxs = embedding.vertexVolToSurfaceIndex( m.FEconnectivity.faces( surfacefacemap, : ) );
    s.edgeends = embedding.vertexVolToSurfaceIndex( m.FEconnectivity.edgeends( surfaceedgeindexes, : ) );
    s.celledges = embedding.edgeVolToSurfaceIndex( m.FEconnectivity.faceedges( surfacefacemap, : ) );
    
    ef = m.FEconnectivity.edgefaces( surfaceedgeindexes, : );
    surfacefacemap = [ false; surfacefacemap ];
    ef( ~surfacefacemap(ef+1) ) = 0;
    ef = sort( ef, 2 );
    s.edgecells = embedding.faceVolToSurfaceIndex( ef(:,[end-1 end]) );
    
    s.nodes = m.FEnodes(surfacevertexindexes,:);
    
    % The above code does not produce consistent orientations of the faces,
    % and cannot be expected to.  If we need this we have to establish it
    % here.
    
    % To make s.celledges consistent with s.tricellvxs, we must ensure that
    % for each ci and i, s.edgeends( s.celledges(ci,i), : ) contains the
    % same two nodes as s.tricellvxs(ci,[j k]) where [j,k] = othersOf3( i
    % ).
    
    
    xx = reshape( s.edgeends( s.celledges', : ), 3, [], 2 );
    ends1 = xx(:,:,1)';
    ends2 = xx(:,:,2)';
    % xx(i,ci,:) is the ends of edge i of cell ci.
    % There are six permutations possible for s.tricellvxs(ci,:).  
    wrong1 = s.tricellvxs==ends1;
    wrong2 = s.tricellvxs==ends2;
    % For each ci, wrong1(ci,:) and wrong2(c1,:) consist of 6 bits.  Not
    % all combinations are possible.  Only the sum of these
    % matters, because the edge ends are listed in arbitrary order:
    wrong = wrong1+wrong2;
    % Each element of this is 0 or 1.
    % Each possible combination should give a permutation on 3 elements.
    % 0 0 0: identity permutation
    % permutation of 1 1 0: swap the places of the two 1s.
    % permutation of 1 0 0: not possible
    % 1 1 1: needs either cyclic permutation of 3.  How do we determine
    % which one?
    
    for ci=1:size(s.tricellvxs,1)
        tcv = s.tricellvxs(ci,:);
        e1 = ends1(ci,:);
        e2 = ends2(ci,:);
        for j=1:3
            p(j) = find( ~any( tcv(j)==[e1;e2], 1 ) );
        end
        s.tricellvxs(ci,p) = s.tricellvxs(ci,:);
    end
    
    if oriented
        s = orientMesh( s );
    end
    
    % embedding.facelocalvxs should list for every face in s.tricellvxs,
    % the local indexes of its vertexes in the tetrahedral element it is
    % a face of, and the fourth vertex.  At this point the ordering of each
    % row of s.tricellvxs is arbitrary.
    % Construct [ s.tricellvxs,
    % m.FEsets.fevxs(embedding.faceSurfaceToVolIndex,:) ]
    % This should have rows of the form [ A B C D E F G ], where [A B C]
    % are all different, [D E F G] are all different, and the former is a
    % subset of the latter.
    % Use [C,IA,IC] = unique(A,'rows','stable')
    [embedding.facelocalvxs,embedding.reindextricellvxs] = ...
        reindex3to4( cast( embedding.vertexSurfaceToVolIndex(s.tricellvxs), class( m.FEsets.fevxs ) ), ...
                     m.FEsets.fevxs(m.FEconnectivity.facefes(embedding.faceSurfaceToVolIndex,1),:) );
end
