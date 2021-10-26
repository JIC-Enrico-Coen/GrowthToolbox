function m = leaf_mgen_radial( m, varargin )
%m = leaf_mgen_radial( m, morphogen, amount, ... )
%   Add to or set the value of a specified morphogen an amount depending
%   on the distance from an origin point.
%
%   Arguments:
%
%   1: The name or index of a morphogen.
%   2: The maximum amount of morphogen to add to every node.
%
%   Options:
%
%       'x', 'y', 'z'   The X, Y, and Z coordinates of the centre of the
%                       distribution, relative to the centre of the mesh.
%                       Default is (0,0,0).
%
%       'nodes'         Only act on the given set of nodes, by default all
%                       of them.  If supplied, the value should be either a
%                       bitmap of all the nodes, or a list of node indexes.
%
%       'add'       A boolean.  If true (the default) the amount will be
%                   added to the current value.  If false, the amount will
%                   replace the current value.
%
%   Examples:
%
%       m = leaf_mgen_radial( m, 'growth', 1, 'x', 0, 'y', 0, 'z', 0 );
%       m = leaf_mgen_radial( m, 'g_anisotropy', 0.8 );
%
%   See also: leaf_mgen_const.
%
%   Equivalent GUI operation: clicking the "Add radial" button in the
%   "Morphogens" panel.  The amount is specified by the "Amount slider and
%   test item.  x, y, and z are specified in the text boxes of those names.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char'}, varargin );
    if ok1
        [ok2, amount, args] = getTypedArg( mfilename(), 'double', args );
    end
    if ~(ok1 && ok2), return; end
    
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultfields( s, 'x', 0, 'y', 0, 'z', 0, 'power', 1, 'add', true );
    if ~isfield( s, 'nodes' )
        s.nodes = true(getNumberOfVertexes( m ),1);
    end
    ok = checkcommandargs( mfilename(), s, 'exact', 'x', 'y', 'z', 'power', 'nodes', 'add' );
    if ~ok, return; end
    
    if isempty(s.nodes), return; end

    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    if usesNewFEs(m)
        theNodes = m.FEnodes;
    else
        theNodes = m.nodes;
    end
    maxpos = max( theNodes, [], 1 );
    minpos = min( theNodes, [], 1 );
    halfrange = (maxpos-minpos)/2;
    meshcentre = sum( theNodes, 1 )/size(theNodes,1);
    growthcentre = meshcentre + [ s.x, s.y, s.z ] .* halfrange;
    m = setradialfield( m, amount, g, growthcentre, s.power, s.add, s.nodes);
end
