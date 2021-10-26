function ab = aabbox( pts )
%ab = aabbox( pts )
%   Return the axis-aligned bounding box of a set of points.
%   pts is an N*K array of N K-dimensional points.  The result is a 2*K
%   array: a(1,:) is the minimum values of the coordinates and ab(2,:) the
%   maximum values.

    ab = [ min(pts,[],1); max(pts,[],1) ];
end
