function m = leaf_icosahedron( m, varargin )
%m = leaf_icosahedron( m, ... )
%   Create a new icosahedral mesh.
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
%       'radius'        The radius of the icosahedron.  Default 1.
%       'refinement'    How many levels of refinement to add.  Default 0.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_circle( [], 'radius', 2, 'rings', 4 );
%
%   Equivalent GUI operation: selecting "Circle" or "Hemisphere" on the
%   pulldown menu on the "Mesh editor" panel, and clicking the "New" or
%   "Replace" button.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'radius', 1, 'refinement', 0, 'thickness', 0, 'new', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'radius', 'refinement', 'thickness', 'new' );
    if ~ok, return; end
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    elseif isempty(m)
        s.new = true;
    end

    newm = newicosmesh();
    newm.nodes = newm.nodes * s.radius;
    m = setmeshfromnodes( newm, m );
    if s.refinement > 0
        for i=1:s.refinement
            m = leaf_refineFEM( m, 'parameter', 1, 'mode', 'random' );
        end
        r = sqrt(sum(m.nodes.^2,2));
        rscale = s.radius./r;
        m.nodes = m.nodes.*repmat( rscale, 1, 3 );
        prismnodesA = m.nodes * (s.radius + m.globalDynamicProps.thicknessAbsolute/2)/s.radius;
        prismnodesB = m.nodes * (s.radius - m.globalDynamicProps.thicknessAbsolute/2)/s.radius;
        m.prismnodes = reshape( [ prismnodesA'; prismnodesB' ], 3, [] )';
    end
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

