function m = leaf_hemisphere( m, varargin )
%m = leaf_hemisphere( m, ... )
%   Create a new hemispherical mesh.  The mesh is oriented so that the cell
%   normals point outwards.
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
%       'diameter'      The diameter of the hemisphere in both x and y
%                       directions.  Default 2.
%       'xwidth'        The diameter of the hemisphere in the x direction.
%                       Default 2.
%       'ywidth'        The diameter of the hemisphere in the y direction.
%                       Default 2.
%       'divisions'     The number of divisions around the circumference.
%                       Default 20.
%       'rings'         The number of circular rings of triangles to divide
%                       it into.  Default is floor(divisions/6).
%       'hollow'        A number >= 0 and < 1.  The default is 0.  If
%                       greater than zero, the semicircle will be made as a
%                       semi-annulus.  The 'innerpts' option will be taken to be
%                       the number of vertexes around the inner edge.
%   Example:
%       m = leaf_hemisphere( [], 'radius', 2, 'divisions', 15, 'rings', 3 );
%
%   Equivalent GUI operation: selecting "Hemisphere" on the pulldown menu on
%   the "Mesh editor" panel, and clicking the "Generate mesh" button.  The
%   radius and the number of rings are specified in the text boxes with
%   those labels.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'xwidth', 0, 'ywidth', 0, 'height', 1, 'rings', 4, ...
        'hollow', 0, 'divisions', 20, 'coneangle', pi/2 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'xwidth', 'ywidth', 'height', 'divisions', 'rings', 'hollow', 'coneangle' );
    if ~ok, return; end
    
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
    
    newm = newcirclemesh( sz, s.divisions, s.rings, [0 0 0], s.hollow );
    
    m = setmeshfromnodes( newm, m );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
end

