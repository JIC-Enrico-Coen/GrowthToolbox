function m = leaf_rectangle( m, varargin )
%m = leaf_rectangle( m, varargin )
%   Create a new rectangular mesh.
%
%   Arguments:
%       M is either empty or an existing mesh.  If it is empty, then an
%       entirely new mesh is created, with the default set of morphogens
%       If M is an existing mesh, then its geometry is replaced by the new
%       mesh.  It retains the same set of morphogens (all set to zero
%       everywhere on the new mesh), interaction function, and all other
%       properties not depending on the specific geometry of the mesh.
%
%   Options:
%       'xwidth'  The width of the rectangle in the X dimension.  Default 2.
%       'ywidth'  The width of the rectangle in the Y dimension.  Default 2.
%       'centre'  Where the centre of the rectangle should be.
%       'xdivs'   The number of finite element cells along the X dimension.
%                 Default 8.
%       'ydivs'   The number of finite element cells along the Y dimension.
%                 Default 8.
%       'base'    The number of divisions along the side with minimum Y
%                 value.  The default is xdivs.
%       'taper'   The taper in the x and y directions.
%       'fetype'  EXPERIMENTAL, NOT FULLY IMPLEMENTED.  Specify the type of
%                 finite elements to use.  This is a string which must be
%                 one of the following:  'P6', 'H8', "H8Q', 'T3', 'Q4'.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_rectangle( [], 'xwidth', 2, 'ywidth', 2, 'xdivs', 8,
%                           'ydivs', 8, 'base', 5 )
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Equivalent GUI operation: selecting "Rectangle" in the pulldown menu in
%   the "Mesh editor" panel and clicking the "New" or "Replace" button.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'xwidth', 2, 'ywidth', 2, 'centre', [0 0 0], ...
        'xdivs', 8, 'ydivs', 8, ...
        'base', 0, 'layers', 0, 'thickness', 0, 'fetype', '', 'new', true );
    ok = checkcommandargs( 'leaf_rectmesh', s, 'only', ...
        'xwidth', 'ywidth', 'centre', 'xdivs', 'ydivs', ...
        'base', 'layers', 'thickness', 'fetype', 'new' );
    if ~ok, m = []; return; end
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    elseif isempty(m)
        s.new = true;
    end
    
    if length(s.xwidth) > 1
        taper(1) = s.xwidth(2)/s.xwidth(1);
    else
        taper(1) = 1;
    end
    if length(s.ywidth) > 1
        taper(2) = s.ywidth(2)/s.ywidth(1);
    else
        taper(2) = 1;
    end

    if isempty( s.fetype )
        newm = makerectmesh( s.xwidth(1), s.ywidth(1), s.centre, [s.base s.xdivs], s.ydivs, taper );
    else
        rectconstructor = [ 'makeRectMesh' s.fetype ];
        if ~exists( [rectconstructor,'.m'], 'file' )
            return;
        end
        [vxcoords,feVxIndexes,gridsize] = makeRectMeshH8Q( N, r );
    end
    m = setmeshfromnodes( newm, m, s.layers, s.thickness );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

