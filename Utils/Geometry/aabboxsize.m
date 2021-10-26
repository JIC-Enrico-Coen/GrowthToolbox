function absize = aabboxsize( pts )
%absize = aabboxsize( pts )
%   Return the size of the axis-aligned bounding box of a set of points.
%   pts is an N*K array of N K-dimensional points.  The result is a 2*K
%   array: a(1,:) is the minimum values of the coordinates and ab(2,:) the
%   maximum values.

    absize = max(pts,[],1) - min(pts,[],1);
end
