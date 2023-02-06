function m = leaf_cylinder3D( m, varargin )
%   Make a mesh consisting of an axis-aligned cylinder divided
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
%       dimensions of the bounding box of the cylinder.
%
%   'xwidth', 'ywidth', 'zwidth': Alternative way of specifying the
%       bounding box.  If the 'size' option is not given, it defaults to
%       [ xwidth, ywidth, zwidth ].
%
%   'rings': An integer, default 4. This specifies how many concentric
%       cylinders the mesh is divided into.
%
%   'circumdivs': An integer, default 24. This specifies how many edges the
%       circumference of the cylinder is divided into.
%
%   'axisdivs': An integer, default 4. This specifies how many discs
%       the mesh is divided into.
%
%   'position': A 3-element vector, default [0 0 0]. This specifies the
%       position of the centre of the cylinder. 
%
%   'type': A finite element type.  Possibilities are 'T4Q' (the default),
%       and others to be implemented.  'P6' specifies that the block is to
%       be made of linear pentahedra. 'T4' and 'T4Q' specify linear or
%       quadratic tetrahedra respectively (combining in groups of 14 to
%       make pentahedra).
%
%   'subdivision': Either 14 (the default) or 17. This only matters when
%       'type' is T4 or T4Q, and specifies one of two different ways of
%       subdividing a pentahedron into tetrahedra.
%
%   'new':  A boolean, true by default.  If M is
%       empty, true is implied.  True means that an
%       entirely new mesh is created.  False means that
%       new geometry will be created, which will replace
%       the current geometry of M, but leave M with the
%       same set of morphogens and other parameters as it
%       had previously.  (NOT IMPLEMENTED)
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK3D,
%           LEAF_SPHERE3D, LEAF_ICOSAHEDRON3D.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'xwidth', 2, ...
        'ywidth', 2, ...
        'zwidth', 2, ...
        'rings', 4, ...
        'circumdivs', 24, ...
        'innerdivs', 0, ...
        'axisdivs', 4, ...
        'hollow', 0, ...
        'dealign', false, ...
        'coneangle', 0, ...
        'subdivision', 14 );
    s = defaultfields( s, ...
        'size', [ s.xwidth, s.ywidth, s.zwidth ], ...
        'position', [0 0 0], ...
        'type', 'T4Q', ...
        'new', true );
    % We remove 'thickness' because this parameter is not applicable to
    % volumetric  meshes.  This is just a hack to cope with the fact that
    % GFtbox always supplies the thickness value from the GUI, even for
    % volumetric meshes.
    s = safermfield( s, 'xwidth', 'ywidth', 'zwidth', 'thickness' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'size', 'rings', 'circumdivs', 'axisdivs', 'innerdivs', 'hollow', 'position', 'type', 'new', 'dealign', 'coneangle', 'subdivision' );
    if ~ok, return; end
    allowedSubdivs = [14 20];
    if isempty( find( s.subdivision==allowedSubdivs, 1 ) )
        ok = false;
        timedFprintf( 'Option ''subdivision'' must be either %d (the default) or %d, %d found.\n', allowedSubdivs, s.subdivision );
        return;
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

    [circ,~,vxringindexes] = newcirclemesh( [s.size([1 2]) 0], s.circumdivs, s.rings, s.position, s.hollow, s.innerdivs, s.dealign, 1, s.coneangle );
    vxringindexes = vxringindexes(:);
    vxringindexes = 2 * vxringindexes - 1;
    
    [newm,vxparents] = thicken2Dto3D( circ, s.axisdivs, s.size(3), s.type, s.subdivision );
    numvxs = getNumberOfVertexes( newm );
    
    % We want to assign each vertex of the mesh to a ring. To do this, we
    % look at the ring index of the parent of every vertex of the new mesh,
    % if it descends from a vertex of the original flat mesh. We notionally
    % define this index to be 0 for all of the new vertexes introduced by
    % subdividing the pentahedra into tetrahedra.
    %
    % For every vertex of the new mesh we find the set of its neighbouring
    % vertexes, find their ring indexes, and look only at what non-zero
    % ring indexes occur in that set. The ring index of the vertex is the
    % mean of thos indexes (which should always be an integer).
    
    vxnbs = vxVxNbs( newm );
    newvxringindexes = zeros( numvxs, 1 );
    for vi=1:numvxs
        if vxparents(vi,1)==0
            vps = vxparents( vxnbs{vi} );
            vpsnz = vps(vps ~= 0);
            vxris = unique( vxringindexes( vpsnz ) );
            newvxringindexes(vi) = mean( vxris );
        else
            newvxringindexes(vi) = vxringindexes( vxparents(vi,1) );
        end
    end
    
    
    
    newm.plotdefaults.drawedges = 2;
    
    if isempty(m)
        m = newm;
    else
        m = replaceNodes( m, newm );
    end
    s.FEtype = s.type;
    s.type = 'cylinder3d';
    m.meshparams = s;
    m.auxdata.vxringindexes = newvxringindexes;
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

