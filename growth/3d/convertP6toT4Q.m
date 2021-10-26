function m = convertP6toT4Q( m )
%m = convertP6toT4Q( m )
%   Convert a mesh made of pentahedra to one made of quadratic tetrahedra.
%
%   Each pentahedron is divided into 14 tetrahedra.

% The new vertexes in isoparametric coordinates are:
%   Centre: [1/3 1/3 0]
%   Face centres{

global FE_P6 FE_T4Q
    setGlobals();

    centre = [1/3 1/3 0];
    facecentres = [1/2   0 0;
                   1/2 1/2 0;
                   0   1/2 0];

    allvxs = [ FE_P6.canonicalVertexes; centre; facecentres ];
    numOldVxsPerFe = size(FE_P6.canonicalVertexes,1);
    numNewVxsPerFe = size(allvxs,1) - numOldVxsPerFe;
    
    t4vxs = [ 1 2 3 7; % bottom
              4 6 5 7; % top
              1 8 2 7;
              2 8 5 7;
              5 8 4 7;
              4 8 1 7;
              2 9 3 7;
              3 9 6 7;
              6 9 5 7;
              5 9 2 7;
              3 10 1 7;
              1 10 4 7;
              4 10 6 7;
              6 10 3 7];
    quadsPerPenta = size( t4vxs, 1 );
    newt4vxs = t4vxs > numOldVxsPerFe;
    
    m.FEconnectivity = connectivity3D( m );

    vxsPerQuad = 4;
    spaceDims = 3;
    quadfacemap = m.FEconnectivity.faces(:,4)~=0;
    quadfaceindexes = zeros( size(quadfacemap) );
    quadfaceindexes( quadfacemap ) = (1:sum(quadfacemap))';
    quadfaces = m.FEconnectivity.faces( quadfacemap, : );
    quadfacecentres = shiftdim( mean( reshape( m.FEnodes( quadfaces', : ), vxsPerQuad, [], spaceDims ), 1 ), 1 );
    
    vxsPerFE = 6;
    pentacentres = shiftdim( mean( reshape( m.FEnodes( m.FEsets.fevxs', : ), vxsPerFE, [], spaceDims ), 1 ), 1 );
    
    pentacentrebase = size( m.FEnodes, 1 );
    quadcentrebase = pentacentrebase + size( pentacentres, 1 );
    m.FEnodes = [ m.FEnodes; pentacentres; quadfacecentres ];
    
    % For each FE, I need to find the indexes of its vertexes, together
    % with the indexes of its new centre and facecentre vertexes.
    
    fequadfaces = m.FEconnectivity.fefaces(:,3:5); % For each FE, that row of fequadfaces lists its quadrilateral faces.
    
    expandedFEvxs = [ m.FEsets.fevxs, ((pentacentrebase+1):quadcentrebase)', quadcentrebase + quadfaceindexes(fequadfaces) ];
    
    vxsPerT4 = 4;
    t4fevxs = reshape( expandedFEvxs( :, t4vxs' )', vxsPerT4, quadsPerPenta*size(m.FEsets.fevxs,1) )';
    
    m.FEsets = struct( 'fe', FE_T4Q, ...
                       'fevxs', t4fevxs );
    m.FEconnectivity = [];
    m.FEconnectivity = connectivity3D( m );
    m = completeVolumetricMesh( m );
end
