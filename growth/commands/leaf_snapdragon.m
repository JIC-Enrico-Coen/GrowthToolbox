function m = leaf_snapdragon( m, varargin )
%m = leaf_snapdragon( m, ... )
% Make an early stage of a snapdragon flower.  This consists of a number of
% petals, each of which consists of a rectangle surmounted by a semicircle.
% The rectangular parts of the petals are connected to form a tube.
% The mesh is oriented so that the cell normals point outwards.
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
%       'petals'        The number of petals.  Default 5.
%       'radius'        The radius of the tube.  Default 1.
%       'rings'         The number of circular rings of triangles to divide
%                       the semicircular parts into. Default 3.
%       'height'        The height of the rectangle, as a multiple of the
%                       semicircle's diameter.  Default 0.7.
%       'base'          The number of divisions along half of the base of
%                       each  petal. By default this is equal to rings,
%                       i.e. the same as the number at the top of the tube.
%       'strips'        The number of strips of triangles to divide the
%                       tubular part into.  If 0 (the default), this will
%                       be calculated from the height so as to make the
%                       triangles similar in size to those in the lobes.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%
%   Example:
%       m = leaf_snapdragon( [], 'petals', 5, 'radius', 2, 'rings', 4 );
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'petals', 5, 'radius', 2, 'rings', 4, 'height', 0.7, 'strips', 0, ...
        'base', 0, 'baserings', 0, 'bowl', 1, 'thickness', 0.1051, 'new', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'petals', 'radius', 'rings', 'height', 'base', ...
        'baserings', 'strips', 'bowl', 'thickness', 'new' );
    if ~ok, return; end
    if s.strips <= 0
        s.strips = max(1,ceil(s.rings*s.height*s.petals/(pi*s.radius)));
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

    newm = snapdragonmesh( s.petals, s.radius, s.rings, s.height, s.strips, s.base, s.thickness );
    [zmin,bottomedge] = allmin(newm.nodes(:,3));

    % Add base.
    angles = atan2( newm.nodes(bottomedge,2), newm.nodes(bottomedge,1) );
    angles(angles<0) = angles(angles<0) + pi*2;
    angsort = sortrows([angles,bottomedge]);
    sz = [s.radius*2, s.radius*2, -s.radius*s.bowl];
    newm1 = newcirclemesh( sz, length(bottomedge), s.baserings, [0,0,0], ...
                           0, 0, false, 1, 0 );
    halfthickness = s.thickness*s.radius/2;
    newm1.prismnodes = reshape( ...
                        [ newm1.nodes(:,[1 2])';
                          newm1.nodes(:,3)' + halfthickness; ...
                          newm1.nodes(:,[1 2])';
                          newm1.nodes(:,3)' - halfthickness ], ...
                        3, ...
                        [] )';
    newm1.nodes(:,3) = newm1.nodes(:,3) + zmin;
    newm1.prismnodes(:,3) = newm1.prismnodes(:,3) + zmin;
    newm1 = flipOrientation( newm1 );
    numSnapNodes = size(newm.nodes,1);
    numHemiNodes = size(newm1.nodes,1);
    newm.tricellvxs = [ newm.tricellvxs; ...
                        newm1.tricellvxs + numSnapNodes ];
    newm.nodes = [ newm.nodes; newm1.nodes ];
    newm.prismnodes = [ newm.prismnodes; newm1.prismnodes ];

    hemisphereBorder = numSnapNodes ...
        + ((numHemiNodes - length(bottomedge) + 1) : numHemiNodes)';
    newm = stitchmesh( newm, angsort(:,2), hemisphereBorder );

    m = setmeshfromnodes( newm, m );
    m = rectifyVerticals( m );
  % [zmin,bottomedge] = allmin(m.nodes(:,3));
  % m = leaf_fix_vertex( m, 'vertex', bottomedge, 'dfs', 'z' );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
end
