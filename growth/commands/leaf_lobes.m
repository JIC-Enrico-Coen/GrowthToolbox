function m = leaf_lobes( m, varargin )
%m = leaf_lobes( m, ... )
%   Create a new mesh in the form of one or more lobes joined together in a
%   row.  A lobe is a semicircle on top of a rectangle.
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
%       'radius'        The radius of the semicircle.  Default 1.
%       'rings'         The number of circular rings of triangles to divide
%                       it into. Default 4.
%       'height'        The height of the rectangle, as a multiple of the
%                       semicircle's diameter.  Default 0.7.
%       'strips'        The number of strips of triangles to divide the
%                       rectangular part into.  If 0 (the default), this will
%                       be calculated from the height so as to make the
%                       triangles similar in size to those in the lobes.
%       'lobes'         The number of lobes.  The default is 1.
%       'base'          Half the number of divisions along the base of a
%                       lobe.  Defaults to rings.
%       'cylinder'      The series of lobes is to behave as if wrapped
%                       round a cylinder and the two ends stitched
%                       together.  This is implemented by constraining the
%                       nodes on the outer edges in such a way that the
%                       outer edges remain parallel to the y axis.
%       'innercircumference' The number of elements in the central ring of
%                       the semicircular part. The default is 3.
%       'circumference' The number of elements around the circumference of
%                       the semicircular part. The default is
%                       innercircumference times the number of rings.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_lobes( 'radius', 2, 'rings', 4, 'lobes', 3, 'base', 2 );
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Equivalent GUI operation: selecting "Lobes" in the pulldown menu in the
%   "Mesh editor" panel and clicking the "New" or "Replace" button.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'radius', 2, 'rings', 4, 'height', 0.7, 'strips', 0, 'lobes', 1, ...
        'cylinder', 0, 'base', 0, 'layers', 0, 'thickness', 0, ...
        'innercircumference', 0, 'circumference', 0, 'new', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'radius', 'rings', 'height', 'strips', 'lobes', ...
        'base', 'cylinder', 'layers', 'thickness', 'innercircumference', ...
        'circumference', 'new' );
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

    if s.strips <= 0
        s.strips = max(1,ceil(s.rings*s.height/s.radius));
    end
    if s.lobes==1
        newm = lobemesh( s.radius, s.rings, s.height, s.strips, s.base, [s.innercircumference s.circumference] ); % , s.fixright, s.fixfoot );
    else
        newm = lobemesh( s.radius, s.rings, s.height, s.strips, s.base, [s.innercircumference s.circumference] ); % , s.fixright, s.fixfoot );
        leftBorder = newm.borders.left;
        rightBorder = newm.borders.right;
        singleLobe = lobemesh( s.radius, s.rings, s.height, s.strips, s.base, [s.innercircumference s.circumference] ); % , s.fixright, s.fixfoot );
        for i=2:s.lobes-1
            newm = stitchmeshes( singleLobe, newm, rightBorder, leftBorder );
        end
        [newm,renumber] = stitchmeshes( singleLobe, newm, rightBorder, leftBorder );
    end
    newm = centremesh( newm );
    m = setmeshfromnodes( newm, m, s.layers, s.thickness );
    
    % Now set the fixed degrees of freedom.  The nodes along the bottom
    % edge of the rectangle should be fixed in the y dimension.  The
    % nodes along the right-hand side (positive x) of the rectangular part
    % should be fixed in the x dimension.
    
    totalnumnodes = size(m.nodes);

    if false
        if isfield(s,'fixright') && s.fixright
            % The nodes on the right edge are the nth node in the semicircular
            % part, and s.strips nodes at intervals of 2nrings+1, ending at the last node.
            rightedge = [ s.nrings; ((totalnumnodes - (s.strips-1)*(s.nrings+s.nrings+1)) : (s.nrings+s.nrings+1) : totalnumnodes)' ];
            m = leaf_constrain( m, 'vertexes', rightedge, 'dfs', 'x' );
        end
    end
    
    if s.cylinder
        fprintf( 1, '%s: Option ''cylinder'' not implemented.\n', mfilename() );
    end

    ymin = min(m.nodes(:,2));
    ymax = max(m.nodes(:,2));
    delta = (ymax-ymin)/1000;
    bottomedge = find( m.nodes(:,2) < ymin+delta );
    m = leaf_fix_vertex( m, 'vertex', bottomedge, 'dfs', 'y' );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
end
