function m = leaf_bowlz( m, varargin )
%m = leaf_bowlz( m, ... )
%   Add a bowl-shaped perturbation to the z coordinate of every point of
%   the finite element mesh.  The z displacement will be proportional to
%   the square of the distance from the origin of coordinates.
%
%   Options
%
%   amount: A number, being the maximum displacement.  The displacement
%       will be scaled so that the farthest point from the centre is
%       displaced by this amount.  The default is 1.
%
%   centre: The point from which distances are measured, by default the
%       centre of the bounding box.
%
%   axis: Which axis to apply the displacement along. By default this is
%       the axis along which the bounding box is thinnest.
%
%   Examples:
%       m = leaf_bowlz( m, 2 );
%
%   Equivalent GUI operation: the "Bowl Z" button on the "Mesh editor"
%   panel. The amount of bowl deformation is specified by the value in the
%   upper of the two text boxes to the right of the button.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'amount', 0, 'centre', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'centre', 'centre' );
    if ~ok, return; end
    
    if isempty(s.centre)
        s.centre = (min(m.nodes,[],1) + max(m.nodes,[],1))/2;
    end
    m.globalInternalProps.flataxes = getFlatAxes( m );
    m = setbowlz( m, s.amount, s.centre );
end

