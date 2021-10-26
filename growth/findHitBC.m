function [hitBC,hitPoint] = findHitBC( m, ci, hitLine, normalise, thick )
% [hitBC,hitPoint] = findHitBC( m, ci, hitLine, normalise )
%   Given a click on cell ci with the given hitLine, find the barycentric
%   coordinates of the hit point on the cell.  If normalise is true (the
%   default), the barycentric coordinates are forced to lie within the
%   cell.

    if nargin < 4, normalise = true; end
    if thick
        pvxs = m.tricellvxs(ci,:)*2;
        patchVxsB = m.prismnodes( pvxs,: );
        [hitPointB,hitBCB] = lineTriangleIntersection( hitLine, patchVxsB );
        patchVxsA = m.prismnodes( pvxs-1,: );
        [hitPointA,hitBCA] = lineTriangleIntersection( hitLine, patchVxsA );
        hitBC = [ hitBCA; hitBCB ];
        hitPoint = [ hitPointA; hitPointB ];
    else
        patchVxs = m.nodes( m.tricellvxs(ci,:),: );
        [hitPoint,hitBC] = lineTriangleIntersection( hitLine, patchVxs );
    end
    if normalise
        hitBC = normaliseBaryCoords( hitBC );
        % The normalisation is necessary because in practice, I find
        % the hit point can be slightly outside the patch.  Pixel
        % rounding perhaps.
    end
end
