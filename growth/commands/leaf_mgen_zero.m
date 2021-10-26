function m = leaf_mgen_zero( m, morphogen, varargin )
%m = leaf_mgen_zero( m, morphogen, ... )
%   Set the value of a specified morphogen or set of morpphogens to zero
%   everywhere.
%
%   Arguments:
%   morphogen: The name or index of a morphogen, or a cell array of names
%              or an array of indexes. Use 'all' to specify all morphogens.
%
%   Options:
%       'nodes'         Only act on the given set of nodes, by default all
%                       of them.  If supplied, the value should be either a
%                       bitmap of all the nodes, or a list of node indexes.
%
%   Examples:
%       m = leaf_mgen_zero( m, 'growth' );
%
%   See also: LEAF_MGEN_CONST.
%
%   Equivalent GUI operation: clicking the "Set zero" button in the
%   "Morphogens" panel.
%
%   Topics: Morphogens.

    m = leaf_mgen_const( m, morphogen, 0, varargin{:}, 'add', false );
end
