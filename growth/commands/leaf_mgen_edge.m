function m = leaf_mgen_edge( m, morphogen, amount, varargin )
%m = leaf_mgen_edge( m, morphogen, amount, ... )
%   Set the value of a specified morphogen to a given amount everywhere on
%   the edge of the leaf.
%
%   Arguments:
%
%   1: The name or index of a morphogen.
%   2: The maximum amount of morphogen to add to every node.
%
%   Options:
%       'nodes'         Only act on the given set of nodes, by default all
%                       of them.  If supplied, the value should be either a
%                       bitmap of all the nodes, or a list of node indexes.
%
%       'add'       A boolean.  If true (the default) the amount will be
%                   added to the current value.  If false, the amount will
%                   replace the current value.
%
%   Examples:
%       m = leaf_mgen_edge( m, 'kapar', 1 );
%
%   See also: leaf_mgen_const.
%
%   Equivalent GUI operation: clicking the "Add edge" button in the
%   "Morphogens" panel.  The amount is specified by the "Amount slider and
%   test item.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    if ~isfield( s, 'nodes' )
        s.nodes = true(size(m.nodes,1),1);
    end
    s = defaultfields( s, 'add', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'nodes', 'add' );
    if ~ok, return; end

    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    m = setedgegrowth( m, amount, g, s.add, s.nodes );
end
