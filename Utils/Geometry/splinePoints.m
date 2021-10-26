function [interppts,thespline] = splinePoints( pts, interps )
% Given a set of points PTS (an N*3 array) and a vector of value in the
% range 0..1, calculate the positions of a set of points INTERPPTS, such
% that the i'th point is a proportion interps(i) of the way along a smooth
% path through all the given points.
%
% The return value THESPLINE is a data structure from which further
% interpolants can be computed by the PPVAL function.  For example, the
% returned value of INTERPPTS is calculated by:
%
%       interppts = ppval( thespline, interps )';
%
% Note that ppval returns a 3*K array of K points (K being the length of
% INTERPS), so for consistency with our convention that PTS is N*3, this
% array is transposed before being returned.

    diffs = pts(2:end,:) - pts(1:(end-1),:);
    lengths = sqrt( sum( diffs.^2, 2 ) );
    distances = [0; cumsum( lengths ) ];
    distances = distances/distances(end);
    thespline = spline( distances, pts' );
    interppts = ppval( thespline, interps )';
end
