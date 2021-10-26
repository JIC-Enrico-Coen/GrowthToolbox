function m = leaf_lune( m, varargin )
%m = leaf_lune( m, ... )
%   NOT IMPLEMENTED.
%   Create a new mesh in the shape of a stereotypical leaf, oval with
%   pointed ends.
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
%       'xwidth'        The diameter in the X dimension.  Default 3.
%       'ywidth'        The diameter in the Y dimension.  Default 2.
%       'xdivs'         The number of segments to divide it into along the
%                       X axis.  Default 8.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_lune( [], 'xwidth', 3, 'ywidth', 2, 'xdivs', 8 );
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ONECELL,
%           LEAF_RECTANGLE, LEAF_SEMICIRCLE, LEAF_SNAPDRAGON, LEAF_LOBES.
%
%   Equivalent GUI operation: selecting "Leaf" in the pulldown menu in the
%   "Mesh editor" panel and clicking the "New" or "Replace" button.
%
%   Topics: UNIMPLEMENTED, Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'xwidth', 3, 'ywidth', 2, 'xdivs', 8, 'new', true );
    ok = checkcommandargs( 'leaf_leafmesh', s, 'only', ...
        'xwidth', 'ywidth', 'xdivs', 'new' );
    if ~ok, m = []; return; end
    
    complain( '%s: not implemented.\n', mfilename() );
    return;
    
    if isempty(m)
        s.new = true;
    end
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    end

    newm = leafmesh( s.xwidth, s.ywidth, s.xdivs );
    m = setmeshfromnodes( newm, m );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

