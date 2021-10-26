function m = leaf_mgen_linear( m, morphogen, amount, varargin )
%m = leaf_mgen_linear( m, morphogen, amount, ... )
%   Set the value of a specified morphogen to a linear gradient.
%
%   Arguments:
%       1: The name or index of a morphogen.
%       2: If AMOUNT is a single value, this is the maximum amount of
%          morphogen to add to every node, the minimum being zero. If it is
%          a pair [LO,HI], it specifies the range of values.
%
%   Options:
%       'direction'     Either a single number (the angle in degrees
%                       between  the gradient vector and the X axis, the
%                       gradient vector lying in the XY plane; or a triple
%                       of numbers, being a vector in the direction of the
%                       gradient.  The length of the vector does not
%                       matter.  Default is a gradient parallel to the
%                       positive X axis. 
%       'nodes'         Only act on the given set of nodes, by default all
%                       of them.  If supplied, the value should be either a
%                       bitmap of all the nodes, or a list of node indexes.
%
%       'add'       A boolean.  If true (the default) the amount will be
%                   added to the current value.  If false, the amount will
%                   replace the current value.
%
%   Examples:
%       m = leaf_mgen_linear( m, 'growth', 1, 'direction', 0 );
%
%   See also: leaf_mgen_const.
%
%   Equivalent GUI operation: clicking the "Add linear" button in the
%   "Morphogens" panel.  The amount is specified by the "Amount" slider and
%   test item.  Direction is specified in degrees by the "Direction" text
%   box.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    
    if numel(amount)==1
        amount = [0 amount];
    end
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'direction', [1,0,0], 'add', true, 'nodes', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', 'direction', 'nodes', 'add' );
    if ~ok, return; end
    if length(s.direction)==1
        s.direction = s.direction * pi/180;
    end
    
    m = setlinearfield( m, amount, g, s.direction, s.add, s.nodes );
end
