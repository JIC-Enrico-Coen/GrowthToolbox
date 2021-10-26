function intersectDepth = intersectCapsule( capsule0, capsule1 )
%intersectDepth = intersect_capsule( capsule0, capsule1 )
%   Determine whether two capsules intersect.
%   A capsule is a cylinder closed with hemispherical end caps.
%   The data structure representing a capsule is a struct with these
%   fields:
%   ends: a 2xN array, being the two endpoints of the cylinder in
%       N-dimensional space.
%   radius: the radius of the cylinder and the hemispheres.
%   The result is the depth of intersection, positive when they intersect
%   and negative when they do not.  Mathematically, a depth of zero means
%   that they touch, but due to rounding errors this is not a test that can
%   be relied on, and zero should be counted either always as intersecting
%   or always as non-intersecting.

    d = lineLineDistance( capsule0.ends, capsule1.ends );
    intersectDepth = capsule0.radius + capsule1.radius - d;
end
