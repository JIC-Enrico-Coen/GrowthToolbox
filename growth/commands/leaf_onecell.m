function m = leaf_onecell( m, varargin )
%m = leaf_onecell( m, ... )
%   Create a new leaf consisting of a single triangular cell.
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
%       'xwidth'        The diameter in the X dimension.  Default 1.
%       'ywidth'        The diameter in the Y dimension.  Default 1.
%       'zwidth'        The diameter in the Y dimension.  Default 1.
%       'layers'        Number of layers. Default is 0 (meaning one layer,
%                       old-style).
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_onecell( [], 'xwidth', 1, 'ywidth', 1 );
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Equivalent GUI operation: selecting "One cell" in the pulldown menu in
%   the "Mesh editor" panel and clicking the "New" or "Replace" button.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'xwidth', 1, 'ywidth', 1, 'zwidth', 1, 'layers', 0, 'new', true );
    ok = checkcommandargs( 'leaf_onecell', s, 'only', ...
        'xwidth', 'ywidth', 'zwidth', 'layers', 'new' );
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

    newm = onecell( s.xwidth, s.ywidth );
    m = setmeshfromnodes( newm, m, s.layers, s.zwidth );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = 'oneelement';
    
    m = concludeGUIInteraction( handles, m, savedstate );
end
