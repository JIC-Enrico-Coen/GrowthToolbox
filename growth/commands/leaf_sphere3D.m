function m = leaf_sphere3D( m, varargin )
%m = leaf_sphere3D( m, ... )
%   Make a mesh consisting of an axis-aligned ellipsoid divided
%   into volumetric finite elements.
%
%   Arguments:
%       M is either empty or an existing mesh.  If it is empty, then an
%       entirely new mesh is created, with the default set of morphogens.
%       If M is an existing mesh, then its geometry is replaced by the new
%       mesh.  It retains the same set of morphogens (all set to zero
%       everywhere on the new mesh), interaction function, and all other
%       properties not depending on the specific geometry of the mesh.
%
%   Options:
%
%   'size': A 3-element vector, default [2 2 2].  This specifies the
%       dimensions of the ellipsoid.
%
%   'xwidth', 'ywidth', 'zwidth': Alternative way of specifying the size.
%       If the 'size' options is not given, it defaults to
%       [ xwidth, ywidth, zwidth ].
%
%   'position': A 3-element vector, default [0 0 0]. This specifies the
%       position of the centre of the block. 
%
%   'hollow': A real number >= 0 and < 1. If greater than 0, the
%       sphere is hollow, with this value being the relative radius.
%       Values < 0 or >= 1 will be treated as zero.  The default is zero.
%
%   'shells': A positive integer, specifying how many spherical shells the
%       whole is to be made of.  Default 4.
%
%   'segments': An integer, either 8 or 20.  Any value other than 8 will be
%       treated as 20.  This determines whether the mesh is constructed by
%       refining an icosahedron made of 20 tetrahedra, or an octahedron
%       made of 8 tetrahedra.  The resulting mesh will have the symmetry
%       properties of the icosahedron or octahedron respectively.
%
%   'hemisphere': Either a boolean or a string. If false (the default) a
%       sphere is made. If true, a hemisphere is made consisting of the
%       half of the sphere in the direction of the positive Z axis. If a
%       string, then it should be the name of an axis (X, Y, or Z, with
%       case being ignored) followed by a + or a -. A hemisphere will be
%       made consisting of the half of the sphere pointing along the
%       specified axis in the specified direction; thus 'z+' is equivalent
%       to true. If the axis letter is not recognised, it defaults to z; if
%       the sign is missing or not recognised, it defaults to +.
%       When making a hemisphere, the cross-sectional face will be flat if
%       'segment' is 8. If 'segments' is 20, it will be partly ragged.
%
%   'type': A finite element type.  Possibilities are 'H8' (the default),
%       and others to be implemented.  'H8' specifies that the block is to
%       be made of linear hexahedra. 'T4' and 'T4Q' specify linear or
%       quadratic tetrahedra respectively (combining in threes to make
%       blocks).  'P6' specifies linear pentahedra (combining in pairs to
%       make blocks).
%
%   'new': A boolean, true by default.  If M is
%          empty, true is implied.  True means that an
%          entirely new mesh is created.  False means that
%          new geometry will be created, which will replace
%          the current geometry of M, but leave M with the
%          same set of morphogens and other parameters as it
%          had previously.
%
%   These options are identical to those of leaf_block3D.  This procedure
%   works by creating a block, then warping it into an ellipsoid.

% NOT USED:
%   'divisions': A 3-element vector of positive integers, default [2 2 2].
%       This specifies how many finite elements it is divided into along
%       each dimension.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'xwidth', 2, ...
        'ywidth', 2, ...
        'zwidth', 2 );
    s = defaultfields( s, ...
        'size', [ s.xwidth, s.ywidth, s.zwidth ], ...
        'position', [0 0 0], ...
        'shells', 4, ...
        'hollow', 0, ...
        'segments', 20, ...
        'type', 'T4', ...
        'hemisphere', false, ...
        'new', true );
    s = safermfield( s, 'xwidth', 'ywidth', 'zwidth' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'size', 'position', 'shells', 'hollow', 'segments', 'type', 'hemisphere', 'new' );
    if ~ok, return; end
    
    if islogical(s.hemisphere)
        if s.hemisphere
            s.hemisphere = 'z+';
        else
            s.hemisphere = '';
        end
    end
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    elseif isempty(m)
        s.new = true;
    end
    if s.segments ~= 8
        s.segments = 20;
    end
    
    fe = FiniteElementType.MakeFEType(s.type);
    if (fe.typeparams.numboxdims ~= 0) || (fe.typeparams.numsimplexdims ~= 3)
        fprintf( 1, '**** %s: finite element type must be tetrahedral, ''%s'' was given.\n', ...
            mfilename(), s.type );
        return;
    end
    
    s.hollow = max( s.hollow, 0 );
    if s.hollow >= 1
        s.hollow = 0;
    end
    outerradius = 1;
    innerradius = outerradius*s.hollow;
    if innerradius > 0
        interiorshells = max( 1, floor( s.shells * s.hollow / (1-s.hollow) ) );
        minvxshell = interiorshells;
        maxvxshell = minvxshell + s.shells;
    else
        minvxshell = 0;
        maxvxshell = minvxshell + s.shells;
    end
    
    
    
    firstvxi = pyramidindex( minvxshell, 0, 0 );
    lastvxi = pyramidindex( maxvxshell+1, 0, 0 ) - 1;
    lastinteriorvxi = pyramidindex( maxvxshell, 0, 0 ) - 1;
    tetrainnervxscode = pyramidsplitindex( firstvxi:lastinteriorvxi );
    tetrainnervxsindex = pyramidindex( tetrainnervxscode );
    numinwardtetras = size(tetrainnervxscode,1);
    tetra1vxscode = tetrainnervxscode + repmat( [1 0 0], numinwardtetras, 1 );
    tetra1vxsindex = pyramidindex( tetra1vxscode );
    tetra2vxscode = tetrainnervxscode + repmat( [0 1 0], numinwardtetras, 1 );
    tetra2vxsindex = pyramidindex( tetra2vxscode );
    tetra3vxscode = tetrainnervxscode + repmat( [0 0 1], numinwardtetras, 1 );
    tetra3vxsindex = pyramidindex( tetra3vxscode );
    singleinwardtetras = [ tetrainnervxsindex tetra1vxsindex tetra2vxsindex tetra3vxsindex ] - firstvxi;
    
    firstvxi2 = pyramidindex( minvxshell+1, 0, 0 );
    tetraoutervxscode = pyramidsplitindex( firstvxi2:lastvxi );
    tetraoutervxscode = tetraoutervxscode( all(tetraoutervxscode>0,2), : );
    numoutwardtetras = size(tetraoutervxscode,1);
    tetraoutervxsindex = pyramidindex( tetraoutervxscode );
    tetra1vxscode = tetraoutervxscode - repmat( [1 0 0], numoutwardtetras, 1 );
    tetra1vxsindex = pyramidindex( tetra1vxscode );
    tetra2vxscode = tetraoutervxscode - repmat( [0 1 0], numoutwardtetras, 1 );
    tetra2vxsindex = pyramidindex( tetra2vxscode );
    tetra3vxscode = tetraoutervxscode - repmat( [0 0 1], numoutwardtetras, 1 );
    tetra3vxsindex = pyramidindex( tetra3vxscode );
    singleoutwardtetras = [ tetraoutervxsindex tetra1vxsindex tetra2vxsindex tetra3vxsindex ] - firstvxi;
    
    firstoctbaseindex = pyramidindex( [ max(0,minvxshell-1), 0, 0 ] );
    lastoctbaseindex = pyramidindex( maxvxshell-1, 0, 0 ) - 1;
    numocts = lastoctbaseindex - firstoctbaseindex + 1;
    octbasecodes = pyramidsplitindex( firstoctbaseindex:lastoctbaseindex );
    oct1vxscode = octbasecodes + repmat( [1 0 0], numocts, 1 );
    oct2vxscode = octbasecodes + repmat( [0 1 0], numocts, 1 );
    oct3vxscode = octbasecodes + repmat( [0 0 1], numocts, 1 );
    oct23vxscode = max( oct2vxscode, oct3vxscode );
    oct31vxscode = max( oct3vxscode, oct1vxscode );
    oct12vxscode = max( oct1vxscode, oct2vxscode );
    octahedra = [ pyramidindex(oct1vxscode), ...
                  pyramidindex(oct2vxscode), ...
                  pyramidindex(oct3vxscode), ...
                  pyramidindex(oct23vxscode), ...
                  pyramidindex(oct31vxscode), ...
                  pyramidindex(oct12vxscode) ] - firstvxi;
    numoctahedra = size( octahedra, 1);
    vxspertetra = 4;
    spacedims = 3;
    SPLIT4 = false;
    if SPLIT4
%         octasubtetras = [ 1 4 2 3; 1 4 3 5; 1 4 5 6; 1 4 6 2 ];
%   octasubtetras = [ 2 5 3 1; 2 5 1 6; 2 5 6 4; 2 5 4 3 ];
%   octasubtetras = [ 3 6 1 2; 3 6 2 4; 3 6 4 5; 3 6 5 1 ];
    else
        octacentreindexes = ((lastvxi-firstvxi+1):(lastvxi-firstvxi+numoctahedra))';
        octahedra = [ octahedra, octacentreindexes ];
        octafaces = [ 1 2 3; 1 3 5; 1 5 6; 1 6 2; 4 3 2; 4 2 6; 4 6 5; 4 5 3 ];
        octasubtetras = [ octafaces(:,end:-1:1), size( octahedra, 2 )+zeros(8,1) ];
    end
    vxsperoctahedron = size( octahedra, 2 );  % 6 if SPLIT4 is true, 7 if false.
    numsubtetras = size( octasubtetras, 1 );
    octatetras = reshape( octahedra(:,octasubtetras'), numocts, vxspertetra, numsubtetras ); % octagon * tetravxs * subtetra
    octatetras = permute( octatetras, [3 1 2] ); % subtetra * octagon * tetravxs
    octatetras = reshape( octatetras, [], vxspertetra ); % tetra * tetravxs
    
    
    pyramidtetras = [ singleinwardtetras; singleoutwardtetras; octatetras ];
    
    switch s.segments
        case 20
            [icovxs,icotrivxs] = icosahedronGeometry();
            bcAdjustment = 0.5;
        case 8
            [icovxs,icotrivxs] = octahedronGeometry();
            bcAdjustment = 1;
    end
%     icotrivxs = icotrivxs(1:end,:); % FOR DEBUGGING
    numtris = size(icotrivxs,1);
    iv = icovxs(icotrivxs(1,1),:);
    jv = icovxs(icotrivxs(1,2),:);
    kv = icovxs(icotrivxs(1,3),:);
    allvxcodes = pyramidsplitindex( firstvxi:lastvxi );
%     pyramidvxs = allvxcodes * [ iv; jv; kv ];
    pyramidvxs = bcSphericalAdjustment(allvxcodes,bcAdjustment) * [ iv; jv; kv ];
    norms = (sum( allvxcodes, 2 ) - minvxshell) * (outerradius-innerradius)/(maxvxshell - minvxshell) + innerradius;
    pnorms = sqrt(sum(pyramidvxs.^2,2));
    scaling = norms./pnorms;
    if isnan(scaling(1))
        scaling(1) = 0;
    end
    pyramidvxs = pyramidvxs .* repmat( scaling, 1, size(pyramidvxs,2) );
    if ~SPLIT4
        octacentres = shiftdim( sum( reshape( pyramidvxs( octahedra(:,1:(end-1))'+1, : ), vxsperoctahedron-1, numoctahedra, spacedims ), 1 ) / (vxsperoctahedron-1), 1 );
        trueoctanorms = sum( norms( octahedra(:,1:(end-1))'+1 ), 1 )' / (vxsperoctahedron-1);
        octanorms = sqrt(sum(octacentres.^2,2));
        octacentres = octacentres .* repmat( trueoctanorms./octanorms, 1, 3 );
        pyramidvxs = [ pyramidvxs; octacentres ];
    end
    
    g = Geometry( 'id', 'foo', 'vxs', pyramidvxs, ...
        'facevxs', [pyramidtetras(:,[1 2 3]); pyramidtetras(:,[1 2 4]); pyramidtetras(:,[1 3 4]); pyramidtetras(:,[2 3 4])] );
    g.vxcolor = zeros( size(pyramidvxs,1), 1, 'int32' );
    g.color = [0.9 1 1];
    g.alpha = 0.8;
%     figure(1);cla;g.draw(gca); axis equal;view(3);
    % Now we must stitch together eight or twenty copies of pyramidvxs and
    % pyramidtetras.
    
    % 1.  Obtain for each triangle of the polyhedron, a rotation
    % mapping the first triangle to that triangle.
    
    % 1a.  Calculate the rotations to map triangle 1 to every triangle.
    icoframes = reshape( icovxs( icotrivxs', : ), 3, numtris, 3 );  % trivx * tri * dim
    icoframes = permute( icoframes, [1 3 2] );
    icoframe1 = icoframes(:,:,1);
    rotations = zeros( size(icoframes) );
    for i=1:numtris
        rotations(:,:,i) = icoframe1 \ icoframes(:,:,i);
    end
    
    % 1b. Find all of the edges and for each edge, which triangle it is
    % common to.
    edgelinks = reshape( [ icotrivxs(:,[1 2]), ...
                           (3+zeros(numtris,1)), ...
                           (1:numtris)', ...
                           icotrivxs(:,[2 3]), ...
                           (1+zeros(numtris,1)), ...
                           (1:numtris)', ...
                           icotrivxs(:,[3 1]), ...
                           (2+zeros(numtris,1)), ...
                           (1:numtris)' ]', 4, [] )';
    edgelinks(:,[1 2]) = sort( edgelinks(:,[1 2]), 2 );
    edgelinks = sortrows( edgelinks );
    
    repeated = all(edgelinks(1:(end-1),[1 2])==edgelinks(2:end,[1 2]),2);
    
    oppvxdata = [ edgelinks( [repeated;false],[3 4] ) edgelinks( [false;repeated],[3 4] ) ];
    % Each row of oppvxdata is [ fv1 f1 fv2 f2 ].  Faces f1 and f2 share an
    % edge.  Their opposite vertexes have respective indexes in f1 and f2
    % of fv1 and fv2.  fv1 and fv2 tell us which vertexes of the respective
    % pyramids to merge.  oppvxdata is 1-based.
    
    % 2.  For each edge of the icosahedron, we must find the mapping
    % between pyramid vertexes for the corresponding coincident faces.
    
    % The ordering of pyramid codes means that vertexes on face 2 are
    % reversed with respect to faces 1 and 3, hence the interchange of
    % revface2 and face2 below.
    
    allvxcodes = pyramidsplitindex( firstvxi:lastvxi );
    face1 = pyramidindex( allvxcodes(allvxcodes(:,1)==0,:) ) - firstvxi;
    revface2 = pyramidindex( allvxcodes(allvxcodes(:,2)==0,:) ) - firstvxi;
    face3 = pyramidindex( allvxcodes(allvxcodes(:,3)==0,:) ) - firstvxi;
    revfaces = [face1, revface2, face3];
    startseg = 1;
    seglength = minvxshell+1;
    while startseg < size(revfaces,1)
        endseg = startseg + seglength - 1;
        revfaces( startseg:endseg, : ) = revfaces( endseg:-1:startseg, : );
        startseg = endseg+1;
        seglength = seglength+1;
    end
    revface1 = revfaces(:,1);
    face2 = revfaces(:,2);
    revface3 = revfaces(:,3);
    faces = [ face1, face2, face3 ];
    revfaces = [ revface1, revface2, revface3 ];
    
    pairs = zeros(size(faces,1),2,3,3);
    for f1=1:3
        for f2=1:3
            pairs(:,:,f1,f2) = [ faces(:,f1), revfaces(:,f2) ];
        end
    end
    
    
    % 3.  Perform the elision of vertexes.
    
    vxsperpyramid = size(pyramidvxs,1);
    tetrasperpyramid = size(pyramidtetras,1);
    
    % 3a.  Make the vertexes and tetras for all the pyramids.
    allpyramidvxs = zeros( vxsperpyramid*numtris, 3 );
    alltetras = zeros( tetrasperpyramid*numtris, 4, 'int32' );
    for i=1:numtris
        allpyramidvxs((vxsperpyramid*(i-1)+1):(vxsperpyramid*i),:) = pyramidvxs * rotations(:,:,i);
        alltetras((tetrasperpyramid*(i-1)+1):(tetrasperpyramid*i),:) = pyramidtetras + vxsperpyramid*(i-1);
    end
    
    % 3b.  Make the elision list.
    pairsperedge = size(pairs,1);
    allpairs = zeros( pairsperedge*size(oppvxdata,1), 2 );
    for i=1:size(oppvxdata,1)
        fv1 = oppvxdata(i,1);
        f1 = oppvxdata(i,2);
        fv2 = oppvxdata(i,3);
        f2 = oppvxdata(i,4);
        edgepairs = pairs(:,:,fv1,fv2);
        edgepairs(:,1) = edgepairs(:,1) + (f1-1)*vxsperpyramid;
        edgepairs(:,2) = edgepairs(:,2) + (f2-1)*vxsperpyramid;
        allpairs( (pairsperedge*(i-1)+1):(pairsperedge*i), : ) = edgepairs;
    end
    
    g = Geometry( 'id', 'foo', 'vxs', allpyramidvxs, ...
        'facevxs', [alltetras(:,[1 2 3]); alltetras(:,[1 2 4]); alltetras(:,[1 3 4]); alltetras(:,[2 3 4])] );
    g.vxcolor = zeros( size(allpyramidvxs,1), 1, 'int32' );
    g.color = [0.9 1 1];
    g.alpha = 0.8;
    
    zzz = reshape(g.vxs(allpairs'+1,:),2,[],3);
    z1 = squeeze(zzz(1,:,:));
    z2 = squeeze(zzz(2,:,:));
    TOL = 1e-8;
    okpairs = abs(z1-z2) < TOL;
    if ~all(okpairs(:))
        fprintf( 1, '%s: %d of %d vertex pairs do not coincide.\n', ...
            mfilename(), sum(z1(:)~=z2(:)), size(z1,1) );
%         xxxx = 1;
    end

    STITCH_PYRAMIDS = true;
    if STITCH_PYRAMIDS
        renumbervxs = g.elideVertexPairs( allpairs );
        alltetras = renumbervxs(alltetras+1);
    end
%     figure(2);cla;g.draw(gca); axis equal;view(3);
    
    newm.FEnodes = g.vxs .* repmat( s.size/2, size(g.vxs,1), 1 ) + repmat( s.position, size(g.vxs,1), 1 );
    newm.FEsets = struct( 'fe', fe, 'fevxs', alltetras+1 );
    if isempty(m)
        m = completeVolumetricMesh( newm );
    else
        m = replaceNodes( m, newm );
    end
                   
    m = makeedgethreshsq( m );
    m = generateCellData( m );
    m = calculateOutputs( m );
    if ~isempty( s.hemisphere )
        % Make a hemisphere by deleting half of the sphere.
        
        % The axis defaults to z.
        ax = lower(s.hemisphere(1));
        switch ax
            case 'x'
                ax = 1;
            case 'y'
                ax = 2;
            otherwise
                ax = 3;
        end
        % If the sign is missing or unrecognised, it defaults to positive.
        pos = (length(s.hemisphere)==1) || (s.hemisphere(2) ~= '-');
        if pos
            m = leaf_deletenodes( m, m.FEnodes(:,ax) < -s.size(ax)*0.01 );
        else
            m = leaf_deletenodes( m, m.FEnodes(:,ax) > s.size(ax)*0.01 );
        end
    end
    m = concludeGUIInteraction( handles, m, savedstate );
    
end

% function [m,maxradius] = sphericize( m, vertexes )
%     if nargin >= 2
%         surfnodes = vertexes;
%     else
%         surfnodes = m.FEconnectivity.vertexloctype==1;
%     end
%     radii = sqrt(sum(m.FEnodes(surfnodes,:).^2,2));
%     maxradius = max(radii);
% %     minradius = min(radii);
%     scaling = maxradius ./ radii;
% %     err = minradius/maxradius
%     scaling(~isfinite(scaling)) = 1;
%     m.FEnodes(surfnodes,:) = m.FEnodes(surfnodes,:) .* repmat( scaling, 1, 3 );
% end

