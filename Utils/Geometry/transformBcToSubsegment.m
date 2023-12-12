function newbcs = transformBcToSubsegment( subsegbc, bcs )
%transformBcToSubsegment( subsegbc, bcs )
%   SUBSEGBC is a 2*2 array giving two sets of barycentric coordinates
%   defining a nonempty subsegment of some line segment. The global
%   coordinates of the line segment are not needed for this function.
%
%   BCS is a N*2 array giving barycentric coordinates for N points in that
%   line segment.
%
%   The result NEWBCS is the barycentric coordinates of the same points
%   relative to the subsegment.
%
%   None of the points are constrained to lie within either segment.
%
%   The barycentric coordinates must all be valid, i.e. adding to 1. The
%   subsegment must be nonempty. These requirements are not tested for.

    newbcs(:,2) = (bcs(:,2) - subsegbc(1,2)) ./ (subsegbc(2,2) - subsegbc(1,2));
    newbcs(:,1) = 1 - newbcs(:,2);
end
