function [d,pp,bc] = pointLineDistance( vxs, p, wholeLine )
%[d,pp,bc] = pointLineDistance( vxs, p, wholeLine )
%   Find the distance of a point from a line segment.  VXS is a 2*D vector
%   containing the ends of the segment, where D is the number of dimensions.
%   pp is the foot of the perpendicular from p to the line.  bc is the
%   barycentric coordinates of pp with respect to the ends.  If wholeLine
%   is false (the default), then if pp lies outside the 
%   line segment, it will be moved to the nearer end.  However, bc will be
%   unchanged.  To determine from the result whether pp was moved, look at
%   bc: one of its components will be negative in that case.  In both
%   cases, d will be the distance from p to pp.

    if nargin < 3
        wholeLine = false;
    end
    [pp,bc] = projectPointToLine( vxs, p, ~wholeLine );
    d = sqrt(sum((p-pp).^2,2));
end

