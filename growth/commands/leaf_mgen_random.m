function m = leaf_mgen_random( m, morphogen, amount, varargin )
%m = leaf_mgen_random( m, morphogen, amount, ... )
%   Add a random amount of a specified morphogen at each mesh point.
%   Arguments:
%   1: The name or index of a morphogen.
%   2: The maximum amount of morphogen to add to every node.
%   Options:
%       'smoothness'    An integer specifying the smoothness of the
%                       distribution.  0 means no smoothing: the value at
%                       each node is independent of each of its neighbours.
%                       Greater values imply more smoothness.  Default is
%                       2.
%
%       'nodes'         Only act on the given set of nodes, by default all
%                       of them.  If supplied, the value should be either a
%                       bitmap of all the nodes, or a list of node indexes.
%
%       'add'       A boolean.  If true (the default) the amount will be
%                   added to the current value.  If false, the amount will
%                   replace the current value.
%   Examples:
%       m = leaf_mgen_random( m, 'growth', 1 );
%       m = leaf_mgen_random( m, 'g_anisotropy', 0.8 );
%
%   See also: LEAF_MGEN_CONST.
%
%   The values added will range from 0 to amount (whether amount is
%   positive or negative).  At least one vertex will get 0 and at least one
%   will get amount.  The other values will be uniformly randomly distributed
%   throughout that range.
%
%   Equivalent GUI operation: clicking the "Add random" button in the
%   "Morphogens" panel.  The amount is specified by the "Amount slider and
%   test item.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'smoothness', 2 );
    if ~isfield( s, 'nodes' )
        s.nodes = true(size(m.morphogens,1),1);
    end
    s = defaultfields( s, 'add', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'smoothness', 'nodes', 'add' );
    if ~ok, return; end
    
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    m = addrandomfield( m, amount, g, s.smoothness, s.add, s.nodes );
end
