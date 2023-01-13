function m = leaf_cylinder( m, varargin )
%m = leaf_cylinder( m, ... )
%   Create a new surface, in the form of an open-ended cylinder whose axis
%   is the Z axis, centred on the origin.
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
%       'xwidth'        The diameter of the cylinder in the X direction.  Default 2.
%       'ywidth'        The diameter of the cylinder in the Y direction.  Default 2.
%       'centre'        The position of the centre of the cylinder.
%       'height'        The height of the cylinder.  Default 2.
%       'circumdivs'    The number of divisions around the cylinder.
%                       Default 12.
%       'heightdivs'    The number of divisions along the axis of the
%                       cylinder.  Default 4.
%       'basecap'       Boolean.  If true, the foot of the cylinder will be
%                       closed by a hemispherical cap.
%       'baseheight'    The height of the base cap as a fraction of the
%                       radius of the cylinder.  1 will make it exactly
%                       hemispherical, 0 will make it flat.
%       'baserings'     The number of rings of triangles to divide the base
%                       cap into.  If zero, empty, or absent, a default
%                       value will be chosen.
%       'baseflat'      The radius, as a proportion of cylinder radius, of
%                       the flat part of the base. Default 0.
%       'topcap', 'topheight', 'toprings', 'topflat': Similar to basecap,
%                       baseheight, baserings, and 'baseflat'.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%   Example:
%       m = leaf_cylinder( [], 'radius', 2, 'height', 2, 'circumdivs', 12,
%                          'heightdivs', 4 );
%
%   Equivalent GUI operation: selecting "Cylinder" on the pulldown menu on
%   the "Mesh editor" panel, and clicking the "New" or "Replace" button.
%   The radius, height, number of divisions around, and number of divisions
%   vertically are given by the values of the text boxes named "radius",
%   "y width", "x divs", and "y divs" respectively.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'xwidth', 0, 'ywidth', 0, ...
        'centre', [0 0 0], 'height', 2, ...
        'circumdivs', 12, 'heightdivs', 4, ...
        'topcap', false, ...
        'topheight', 1, ...
        'toprings', 0, ...
        'topflat', 0, ...
        'basecap', false, ...
        'baseheight', 1, ...
        'baserings', 0, ...
        'baseflat', 0, ...
        'layers', 0, ...
        'thickness', 0, ...
        'new', true );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'xwidth', 'ywidth', 'centre', 'height', 'circumdivs', 'heightdivs', ...
        'topcap', 'topheight', 'toprings', 'topflat', ...
        'basecap', 'baseheight', 'baserings', ...
        'layers', 'thickness', ...
        'new' );
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

    % Each of xwidth and ywidth defaults to the other.
    % If neither is supplied, they default to 2.
    if s.xwidth == 0
        s.xwidth = s.ywidth;
    elseif s.ywidth == 0
        s.ywidth = s.xwidth;
    end
    if s.xwidth == 0
        s.xwidth = 2;
        s.ywidth = 2;
    end
    
    newm = makecylindermesh( s.xwidth, s.ywidth, s.centre, s.height, s.circumdivs, s.heightdivs, ...
        s.topcap, s.topheight, s.toprings, ...
        s.basecap, s.baseheight, s.baserings );
    m = setmeshfromnodes( newm, m, s.layers, s.thickness );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    if s.topcap
        if s.basecap
            m.meshparams.type = 'capsule';
        else
            m.meshparams.type = 'cap';
        end
    elseif s.basecap
        m.meshparams.type = 'cup';
    else
        m.meshparams.type = 'cylinder';
    end
    
    m = concludeGUIInteraction( handles, m, savedstate );
end
