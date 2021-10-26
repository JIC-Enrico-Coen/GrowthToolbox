function m = leaf_octahedron3D( m, varargin )
%m = leaf_octahedron3D( m, ... )
%   Make a volumetric octahedron split into four tetrahedra.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'xwidth', 2, ...
        'ywidth', 2, ...
        'zwidth', 2 );
    s = defaultfields( s, ...
        'size', [ s.xwidth, s.ywidth, s.zwidth ], ...
        'position', [0 0 0], ...
        'taper', '0', ...
        'type', 'T4Q', ...
        'new', true );
    s = safermfield( s, 'xwidth', 'ywidth', 'zwidth' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'size', 'position', 'taper', 'type', 'new' );
    if ~ok, return; end

    s.taper = max(-1,min(1,s.taper));
    theta = pi*2/3;
    ct = cos(theta);
    st = sin(theta);
    x0 = [1 0 -1];
    x1 = [ct -st -1];
    x2 = [ct st -1];
    vxs = [x0; x1; x2];
    vxs = [ vxs; -vxs ];
    vxs(1:3,[1 2]) = vxs(1:3,[1 2]) * (1-s.taper);
    vxs(4:6,[1 2]) = vxs(4:6,[1 2]) * (1+s.taper);
    vxs = vxs*diag(s.size/2) + repmat( s.position, size(vxs,1), 1 );
    
    tetras = [ 1 4 2 3; 1 4 3 5; 1 4 5 6; 1 4 6 2 ];
%   tetras = [ 2 5 3 1; 2 5 1 6; 2 5 6 4; 2 5 4 3 ];
%   tetras = [ 3 6 1 2; 3 6 2 4; 3 6 4 5; 3 6 5 1 ];

    fe = FiniteElementType.MakeFEType(s.type);
    newm.FEnodes = vxs;
    newm.FEsets = struct( 'fe', fe, 'fevxs', tetras );
    if isempty(m)
        m = completeVolumetricMesh( newm );
    else
        m = replaceNodes( m, newm );
    end

end
