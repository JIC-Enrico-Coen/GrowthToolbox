function bc = bcSphericalAdjustment( bc, amount )
%bc = bcSphericalAdjustment( bc, amount )
%   When projecting a triangle to a sphere, points that were equally spaced
%   in the triangle will have varying spacing on the sphere.  This function
%   provides a rather crude method of compensating for this in order to
%   obtain a more even distribution of points on the sphere.
%
%   BC is an N*3 array of barycentric coordinates for a flat triangle.
%   These need not add up to 1.  The result BC is N*3, and each row will
%   have the same sum as the original, but points close to the vertexes
%   are moved farther away from the vertexes.
%
%   The AMOUNT parameter sets the amount of correction.  A value of 1 for a
%   face of an octahedron and 0.5 for a face of an icosahedron work well.
%   0 makes no adjustment.
%
%   For all values of AMOUNT, vertexes are mapped to vertexes, edges to
%   edges (with altered spacing along the edges) and the centre of the
%   spherical triangle is mapped to  the centre.

% This works by adding ax(x-1)(x-1/3) to every value x in BC, then scaling
% each row of BC to have the same sum as originally.  x(x-1)(x-1/3) has
% zeros at 0, 1/3, and 1, so these values are left unchanged.

    s = sum(bc,2);  % Store the sums in order to restore them later.
    bc = bc ./ repmat( s, 1, size(bc,2) );  % Scale all coordinate sets to sum to 1.
    bc = bc + amount*bc.*(bc-1).*(bc-1/3);  % Apply the adjustment.
    bc = bc .* repmat( s./sum(bc,2), 1, size(bc,2) );  % Rescale to the original sums.
    bc(isnan(bc)) = 0;  % Restore any rows that were originally all zero.
end
