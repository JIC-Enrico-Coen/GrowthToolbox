function [csep,csz] = clumpsepsize( v, bigness )
%[csep,csz] = clumpsepsize( v )
%   Returns the results of clumpsize(v) and clumpseparation(v), but is more
%   efficient than calling both of those separately.
%
%   See also: clumpsize, clumpseparation, clumplinear.

    if nargin < 2
        bigness = 1;
    end
    
    vs = sort(v);
    vdiff1 = diffs(vs);
    midDiff = (max(vdiff1) + min(vdiff1))/2;
    bigdiffs = find(vdiff1 > midDiff*bigness);
    if isempty(bigdiffs)
        bigdiffs = 1:length(vdiff1);
    end
    nbd = length(bigdiffs);
    rangefirst = vs(bigdiffs(1)) - vs(1);
    rangelast = vs(length(vs)) - vs(bigdiffs(nbd)+1);
    rangeother = vs(bigdiffs(2:nbd)) - vs(bigdiffs(1:(nbd-1))+1);
    csz = max(max(rangefirst,rangelast),max(rangeother));
    csep = max(diffs(sort(vdiff1)));
end
