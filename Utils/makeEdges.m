function [edgevxs,edgefaces,faceedges] = makeEdges( faces )
%[edgevxs,edgefaces,faceedges] = makeEdges( faces )
%   Given a set of "faces" (defined as lists of "vertex" indexes),
%   calculate other connectivity information.
%
%   EDGEVXS will be an E*2 array of E pairs of vertex indexes.
%
%   EDGEFACES will be an 1*E cell array listing all the faces that each
%   edge belongs to.
%
%   FACEEDGES will be a 1*F cell array listing all the edges that each
%   face includes, in an order that matched the vertex order. Where
%   vertexes v1 and v2 occur as the i'th and (i+1)'th vertexes of a face,
%   then the i'th edge of that face connects v1 and v2 (in either order).

    if isnumeric( faces )
        faces = raggedToCellArray( faces, int32(0) );
    end
    numFaces = length( faces );
    allvxs = cell2mat( faces );
    numVxs = max( allvxs );
    
    es = false( numVxs, numVxs );
    for fi=1:numFaces
        facevxpairs = [ reshape( faces{fi}, [], 1 ), reshape( faces{fi}([2:end,1]), [], 1 ) ];
        es( sub2ind( [numVxs, numVxs], facevxpairs(:,1), facevxpairs(:,2) ) ) = true;
    end
    es = tril(es | es');
    edgeentries = find( es(:) );
    numedges = length( edgeentries );
    [e1,e2] = ind2sub( [numVxs, numVxs], edgeentries );
    edgevxs = [e2,e1];
    edgeindexes = zeros( [numVxs, numVxs] );
    edgeindexes( edgeentries ) = 1:numedges;
    edgeindexes = max( edgeindexes, edgeindexes' );
    
    faceedges = cell( numFaces, 1 );

    edgefacesA = cell( numFaces, 1 );
    for fi=1:numFaces
        facevxpairs = [ reshape( faces{fi}, [], 1 ), reshape( faces{fi}([2:end,1]), [], 1 ) ];
        fes = edgeindexes( sub2ind( [numVxs, numVxs], facevxpairs(:,1), facevxpairs(:,2) ) );
        faceedges{fi} = fes;
        edgefacesA{fi} = [ fi+zeros(size(fes)), fes ];
    end
    
    edgefacesB = cell2mat( edgefacesA );
    edgefaces = map2cell( edgefacesB(:,[2 1]) );

%     faceedgesX = map2cell( edgefacesB );
end
