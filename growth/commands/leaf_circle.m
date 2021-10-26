function [m,ok] = leaf_circle( m, varargin )
%m = leaf_circle( m, ... )
%   Create a new circular mesh.
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
%       'xwidth'        The diameter of the circle in the x direction.  Default 2.
%       'ywidth'        The diameter of the circle in the y direction.  Default 2.
%       'rings'         The number of circular rings of triangles to divide
%                       it into. Default 4.
%       'circumpts'     The number of vertexes around the circumference.
%                       The default is 6*rings/(1-hollow).  It must be at
%                       least 4, and for best results should be at least
%                       4*rings/(1-hollow).  If zero is specified, this
%                       means to use the default.
%       'innerpts'      The number of edges around the innermost ring of
%                       edges. If hollow==0 the default is
%                       max( floor(circum/nrings), 3 ), otherwise
%                       max( floor(circum*hollow), 3 ).
%       'dealign'       Dealign the vertexes on adjacent rings. Default
%                       false.  Only applies when circumpts is nonzero.
%       'coneangle'     Make a circular cap of a sphere instead of a flat
%                       circle.  The surface can be defined as the
%                       intersection of the surface of a sphere with a cone
%                       whose apex is at the centre of the sphere.  The
%                       value of coneangle is the angle between the axis of
%                       the cone and the surface of the cone.  The default
%                       is zero, i.e. make a flat circle.  If coneangle is
%                       negative, the spherical cap is made in the -z
%                       direction.  coneangle should be between -PI and PI.
%       'height'        Modify the height of the circular cap specified by
%                       coneangle, by scaling the z-axis to make the height
%                       of the centre of the cap above the plane of its rim
%                       equal to the specified value.  If coneangle is not
%                       specified, and height is non-zero, then coneangle
%                       defaults to PI/2.  If coneangle is specified and
%                       height is not, then height defaults to thevalue for
%                       a spherical cap, i.e. height = radius(1 -
%                       cos(coneangle), where radius = sqrt(xwidth*ywidth).
%       'generalFE'     Use new-style finite elements to build the mesh.
%                       Default is false.
%       'semicircle'    If true (the default is false) a semicircle will be
%                       created by removing all vertexes with negative Y
%                       coordinate.
%       'hollow'        A number >= 0 and < 1.  The default is 0.  If
%                       greater than zero, the circle will be made as an
%                       annulus.  The 'innerpts' option will be taken to be
%                       the number of vertexes around the inner edge.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously.
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
    s = defaultfields( s, 'xwidth', 0, 'ywidth', 0, 'centre', [0 0 0], 'rings', 4, ...
        'circumpts', 0, 'innerpts', 0, 'dealign', 0, 'height', 0, 'asym', [], ...
        'coneangle', 0, 'layers', 0, 'thickness', 0, 'generalFE', false, ...
        'semicircle', false, 'hollow', false, 'new', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'xwidth', 'ywidth', 'centre', 'rings', 'circumpts', 'innerpts', 'dealign', ...
        'height', 'asym', 'coneangle', 'layers', 'thickness', 'generalFE', ...
        'semicircle', 'hollow', 'new' );
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
    sz = [s.xwidth, s.ywidth, s.height*sqrt( (s.xwidth * s.ywidth)/4 )];
    s.hollow = max( s.hollow, 0 );
    if s.hollow >= 1
        s.hollow = 0;
    end
    
    newm = newcirclemesh( sz, s.circumpts, s.rings, s.centre, s.hollow, s.innerpts, s.dealign, 1, s.coneangle );
    m = setmeshfromnodes( newm, m, s.layers, s.thickness );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    if s.height==0
        m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    else
        m.meshparams.type = 'hemisphere';
    end
    
    if ~isempty(s.asym)
        xmax = max( m.nodes(:,1) );
        ymax = max( m.nodes(:,2) );
        ry = sqrt(1 - (m.nodes(:,2)/ymax).^2);
        xmax_x = ry*xmax;
        if s.asym >= 0
            m.nodes(:,1) = xmax_x*(s.asym/2) + m.nodes(:,1) *((2-s.asym)/2);
        else
            m.nodes(:,1) = xmax_x*(s.asym/2) + m.nodes(:,1) *((2+s.asym)/2);
        end
        m.prismnodes(:,1) = reshape( repmat( m.nodes(:,1)', 2, 1 ), [], 1 );
    end
    
    if s.semicircle
        delvxs = find( m.nodes(:,2) < 0.001*sz(2) );
        m = deletepoints( m, delvxs' );
        m.meshparams = safemakestruct( '', varargin );
        m.meshparams.randomness = 0;
        m.meshparams.type = 'semicircle';
    end
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

