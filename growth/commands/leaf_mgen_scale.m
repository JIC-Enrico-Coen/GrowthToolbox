function m = leaf_mgen_scale( m, morphogen, scalefactor, varargin )
%m = leaf_mgen_scale( m, morphogen, scalefactor )
%   Scale the value of a given morphogen by a given amount.
%
%   Arguments:
%
%   1: The name or index of a morphogen, or a cell array of names or an
%      array of indexes.
%   2: The scale factor.
%
%   Options:
%
%   'nodes'     Only act on the given set of nodes, by default all
%               of them.  If supplied, the value should be either a
%               bitmap of all the nodes, or a list of node indexes.
%
%   'midvalue'  Each morphogen value x will be replaced by
%               midvalue + scalefactor*(x-midvalue).  That is, the distance
%               of each value from midvalue will be scaled. The default
%               value for midvalue is zero.
%
%   Examples:
%       m = leaf_mgen_scale( m, 'kapar', -1 );
%
%   See also: leaf_mgen_const.
%
%   Equivalent GUI operation: clicking the "Invert" button in the
%   "Morphogens" panel will scale the current morphogen by -1. There is not
%   yet a user interface for a general scale factor.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    if ~isfield( s, 'nodes' )
        s.nodes = true(size(m.morphogens,1),1);
    end
    if isempty(s.nodes), return; end
    s = defaultfields( s, 'midvalue', 0 );
    ok = checkcommandargs( mfilename(), s, 'exact', 'nodes', 'midvalue' );
    if ~ok, return; end
    
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    m.morphogens(s.nodes,g) = s.midvalue + (m.morphogens(s.nodes,g)-s.midvalue) * scalefactor;
end
