function m = leaf_saddlez( m, varargin )
%m = leaf_saddlez( m, ... )
%   Add a saddle-shaped displacement to the nodes of m.
%   Options:
%       'amount'    The maximum amount of the displacement, which is
%                   proportional to the distance from the origin.  Default
%                   1.
%       'lobes'     How many complete waves the displacemnt creates on the
%                   edge (an integer, minimum value 2).  Default 2.
%   Example:
%       m = leaf_saddlez( m, 'amount', 1, 'lobes', 2 );
%
%   Equivalent GUI operation: the "Saddle Z" button on the "Mesh editor"
%   panel. The amount of saddle deformation is specified by the value in
%   the upper of the two text boxes to the right of the button.  The number
%   of waves is specified by the lower text box.
%
%   Topics: Mesh editing

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'amount', 1, 'lobes', 2 );
    ok = checkcommandargs( 'leaf_saddlez', s, 'only', ...
        'amount', 'lobes' );
    if ~ok, return; end
    
    m.globalInternalProps.flataxes = getFlatAxes( m );
    m = setsaddlez( m, s.amount, s.lobes );
    m = rectifyVerticals( m );
end

