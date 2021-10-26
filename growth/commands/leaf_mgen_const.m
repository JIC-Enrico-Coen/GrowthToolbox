function m = leaf_mgen_const( m, morphogen, amount, varargin )
%m = leaf_mgen_const( m, morphogen, amount, ... )
%   Add a constant amount to the value of a specified morphogen everywhere.
%   Arguments:
%   1: The name or index of a morphogen.
%   2: The amount of morphogen to add to every node.  A value
%      of 1 will give moderate growth or bend, and a maximum growth or
%      bend anisotropy.  A constant field of growth or bend polarizer
%      has no effect: polarising morphogen has an effect only through
%      its gradient.
%
%   Options:
%
%       'nodes'     Only act on the given set of nodes, by default all
%                   of them.  If supplied, the value should be either a
%                   bitmap of all the nodes, or a list of node indexes.
%
%       'add'       A boolean.  If true (the default) the amount will be
%                   added to the current value.  If false, the amount will
%                   replace the current value.
%   Examples:
%       m = leaf_mgen_const( m, 'growth', 1 );
%       m = leaf_mgen_const( m, 3, 0.8 );
%
%   See also: LEAF_MGEN_RADIAL.
%
%   Equivalent GUI operation: clicking the "Add const" button in the
%   "Morphogens" panel.  The amount is specified by the "Amount slider and
%   test item.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if nargin < 3, return; end  % Not enough arguments to do anything.
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    if ~isfield( s, 'nodes' )
        s.nodes = true(size(m.morphogens,1),1);
    end
    s = defaultfields( s, 'add', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'nodes', 'add' );
    if ~ok, return; end
    
    mgenIndexes = FindMorphogenIndex( m, morphogen, mfilename() );
    m = setconstantfield( m, amount, mgenIndexes, s.add, s.nodes );
end
