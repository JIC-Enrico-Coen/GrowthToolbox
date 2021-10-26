function csz = clumpsize( v, bigness )
%csz = clumpsize( v )
%   v is a vector which is expected to consist of a large number of values
%   that fall into clumps clustered around a smaller number of values.  The
%   spread of values within each clump is expected to be much smaller than
%   the difference of values between any two clumps.  This routine returns
%   the maximum separation found between any two members of the same clump.
%   v can be a row or column vector.
%
%   See also: clumpseparation, clumpsepsize, clumplinear.

    if nargin < 2
        bigness = 1;
    end
    
    vs = sort(v(:));
    vdiff1 = diffs(vs);
    midDiff = (max(vdiff1) + min(vdiff1))/2;
    bigdiffs = find(vdiff1 > midDiff*bigness);
    if isempty(bigdiffs)
        bigdiffs = 1:length(vdiff1);
    end
    diffsizes = vs(bigdiffs+1) - vs(bigdiffs);
    csz = max(diffsizes);
end
