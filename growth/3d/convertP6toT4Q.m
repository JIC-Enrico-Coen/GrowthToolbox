function [m,vxparents,feparents,ok] = convertP6toT4Q( m, varargin )
%[m,vxparents,feparents,ok] = convertP6toT4Q( m, ... )
%   Convert a mesh made of pentahedra to one made of quadratic tetrahedra.
%
%   Each pentahedron is divided into either 14 or 17 tetrahedra, depending
%   on the options.
%
%   vxparents is an N*3 matrix which maps each vertex of the new mesh to
%   its parent in the old mesh. This parent is either a vertex (column 1),
%   a face (column 2), or an element (column 3).
%
%   Options:
%
%   'subdivision'  Either 14 (the default) or 20. These specify two
%       different ways of subdividing the pentahedron, one into 14
%       tetrahedra and one into 20.

% The new vertexes in isoparametric coordinates are:
%   Centre: [1/3 1/3 0]
%   Face centres{

global FE_P6 FE_T4Q

    setGlobals();
    
    vxparents = [];
    feparents = [];
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'subdivision', 14 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'subdivision' );
    if ~ok, return; end
    allowedSubdivs = [14 20];
    if isempty( find( s.subdivision==allowedSubdivs, 1 ) )
        ok = false;
        timedFprintf( 'Option ''subdivision'' must be either %d (the default) or %d, %d found.\n', allowedSubdivs, s.subdivision );
        return;
    end

    numOldFEs = getNumberOfFEs( m );
    
    div14 = s.subdivision==14;
    
    % The table t4vxs is constructed from the definition of FE_P6. We give
    % the explicit values here as a check. t4vxsCheck should be identical
    % to t4vxs.
    t4vxsCheck = [ 1 2 3 7; % bottom
                   4 6 5 7; % top
                   1 8 2 7; % side 1
                   2 8 5 7; % side 1 *
                   5 8 4 7; % side 1
                   4 8 1 7; % side 1 *
                   2 9 3 7; % side 2
                   3 9 6 7; % side 2
                   6 9 5 7; % side 2
                   5 9 2 7; % side 2
                   3 10 1 7; % side 3
                   1 10 4 7; % side 3
                   4 10 6 7; % side 3
                   6 10 3 7]; % side 3
    fep6faces = FE_P6.faces';
    fep6_trifaces = fep6faces(:,end)==0;
    numTriFaces = sum( fep6_trifaces );
    fep6_quadfaces = ~fep6_trifaces;
    numQuadFaces = sum( fep6_quadfaces );
    feCentreIndex = size( FE_P6.canonicalVertexes, 1 ) + 1;
    quadCentreIndexes = feCentreIndex + (1:sum(fep6_quadfaces))';
    if div14
        edgeCentreIndexes = [];
    else
        edgeCentreIndexes = quadCentreIndexes(end) + (1:3)';
    end
    
    endFEs = [ fep6faces( fep6_trifaces, [1 3 2] ), repmat( feCentreIndex, numTriFaces, 1 ) ];
    quadFaceVxs = fep6faces( fep6_quadfaces, : );
    if div14
        rectFaceVxs = quadFaceVxs;
    else
        rectFaceVxs = [ quadFaceVxs(:,[1 2]), edgeCentreIndexes([3 1 2],1), quadFaceVxs(:,[3 4]), edgeCentreIndexes([2 3 1],1) ];
    end
    newVxsPerQuad = size(rectFaceVxs,2);
    quadVxPairs = reshape( [ 1:newVxsPerQuad; [2:newVxsPerQuad 1] ], 1, [] );
    foo = reshape( rectFaceVxs( :, quadVxPairs )', 2, size(rectFaceVxs,2)*numQuadFaces )';
    foo2 = reshape( repmat( quadCentreIndexes', size(rectFaceVxs,2), 1 ), [], 1 );
    t4vxs1 = [ foo(:,1), foo2, foo(:,2), repmat( feCentreIndex, numQuadFaces*size(rectFaceVxs,2), 1 ) ];
    t4vxs = [ endFEs; t4vxs1 ];
    
    quadsPerPenta = size( t4vxs, 1 );
    
    m.FEconnectivity = connectivity3D( m );

    oldNumVxs = getNumberOfVertexes( m );
    
    oldvxsPerQuad = 4;
    spaceDims = 3;
    quadfacemap = m.FEconnectivity.faces(:,4)~=0;
    quadfaceindexes = zeros( size(quadfacemap) );
    quadfaceindexes( quadfacemap ) = (1:sum(quadfacemap))';
    quadfaces = m.FEconnectivity.faces( quadfacemap, : );
    quadfacecentres = shiftdim( mean( reshape( m.FEnodes( quadfaces', : ), oldvxsPerQuad, [], spaceDims ), 1 ), 1 );
    
    vxsPerFE = 6;
    pentacentres = shiftdim( mean( reshape( m.FEnodes( m.FEsets.fevxs', : ), vxsPerFE, [], spaceDims ), 1 ), 1 );
    
    pentacentrebase = size( m.FEnodes, 1 );
    quadcentrebase = pentacentrebase + size( pentacentres, 1 );
    edgecentrebase = quadcentrebase + size( quadfacecentres, 1 );

    if div14
        edgecentres = zeros(0,3);
        edgecentreindexes = zeros(0,3);
    else
        % Find the edges that are to be split
        trifaces = fep6faces( fep6_trifaces, 1:3 );
        trifaceedges = sort( reshape( trifaces(:,[1 2 2 3 3 1])', 2, [] ), 1 )';
        fep6edges = FE_P6.edges';
        [fep6vertedgeends,fep6vertedges] = setdiff( fep6edges, trifaceedges, 'rows' );
        [oldverticaledges,ia,ic] = unique( m.FEconnectivity.feedges(:,fep6vertedges) );
        ic = reshape( ic, [], length(fep6vertedges) );
        uniqueEdgeEnds = m.FEconnectivity.edgeends( oldverticaledges, : );
        edgecentres = (m.FEnodes(uniqueEdgeEnds(:,1),:) + m.FEnodes(uniqueEdgeEnds(:,2),:))/2;
        edgecentreindexes = ic;
    end
    
    m.FEnodes = [ m.FEnodes; pentacentres; quadfacecentres; edgecentres ];
    
    % For each FE, I need to find the indexes of its vertexes, together
    % with the indexes of its new centre and facecentre vertexes, and
    % edgecentre vertexes when s.subdivision = 17.
    
    fequadfaces = m.FEconnectivity.fefaces(:,fep6_quadfaces); % For each FE, that row of fequadfaces lists its quadrilateral faces.
    
    expandedFEvxs = [ m.FEsets.fevxs, ...
                      ((pentacentrebase+1):quadcentrebase)', ...
                      quadcentrebase + quadfaceindexes(fequadfaces), ...
                      edgecentrebase + edgecentreindexes(:,[3 1 2]) ];
                  % The [3 1 2] above has to do with the order that the
                  % quad faces of an FE_P6 are listed in the definition of
                  % that finite element type. It should be calculated
                  % instead of just inserted here.
    
    vxsPerT4 = 4;
    t4fevxs = reshape( expandedFEvxs( :, t4vxs' )', vxsPerT4, quadsPerPenta*size(m.FEsets.fevxs,1) )';
    
    m.FEsets = struct( 'fe', FE_T4Q, ...
                       'fevxs', t4fevxs );
    m.FEconnectivity = [];
    m.FEconnectivity = connectivity3D( m );
    m = completeVolumetricMesh( m );
    
    newNumVxs = getNumberOfVertexes( m );
    numPentaCentres = size(pentacentres,1);
    numFaceCentres = size(quadfacecentres,1);
    numEdgeCentres = size(edgecentres,1);
    vxparents = zeros( newNumVxs, 4 );
    base = 0;
    vxparents( (base+1):(base+oldNumVxs), 1 ) = (1:oldNumVxs)';
    base = base+oldNumVxs;
    vxparents( (base+1):(base+numPentaCentres), 2 ) = (1:numPentaCentres)';
    base = base+numPentaCentres;
    vxparents( (base+1):(base+numFaceCentres), 3 ) = (1:numFaceCentres)';
    base = base+numFaceCentres;
    vxparents( (base+1):(base+numEdgeCentres), 4 ) = (1:numEdgeCentres)';
    feparents = reshape( repmat( 1:numOldFEs, quadsPerPenta, 1 ), [], 1 );
end
