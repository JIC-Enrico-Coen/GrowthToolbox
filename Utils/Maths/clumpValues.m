function [clumpindex,clumpwidths,clumpcentres] = clumpValues( v, maxclumpdiff )
%[clumpindex,clumpwidths] = clumpValues( v, maxclumpdiff )
%   v is a vector which is expected to consist of a large number of values
%   that fall into clumps clustered around a smaller number of values.
%   This routine finds such a clumping.
%
%   The result clumpindex gives the index of the clump that each member of
%   v belongs to. The clumps are indexed in ascending order of their means.
%
%   v can have any shape. clumpindex will have the same shape as v.
%
%   clumpwidths gives for each clump, the difference between its
%   maximum and minimum elements. It is returned as a row vector.
%
%   clumpcentres gives the mean of each clump.
%
%   If maxclumpdiff is specified, then that will be the maximum difference
%   between consecutive elements (in sorted order) of the same clump. Note
%   that the width of a clump may be larger than this, and in principle
%   arbitrarily large.

    if nargin < 2
        maxclumpdiff = 0;
    end

    if isempty(v)
        clumpindex = [];
        clumpwidths = [];
        return;
    end

    if numel(v)==1
        clumpindex = 1;
        clumpwidths = 0;
        return;
    end

    sz = size(v);
    [sv,pv] = sort( v(:) );
    dv = diffs(sv);

    if numel(sv)==2
        if nargin < 2
            clumpindex(pv) = [1 1];
            clumpwidths = [0];
        else
            if dv < maxclumpdiff
                clumpindex(pv) = [1 1];
                clumpwidths = [0];
            else
                clumpindex(pv) = [1 2];
                clumpwidths = [0 0];
            end
        end
        return;
    end
    
    if nargin < 2
        maxclumpdiff = max(diffs(sort(dv)));
    end
    
    steps = dv >= maxclumpdiff;
    clumpindex = 1 + [0; cumsum(steps)];
    clumpends = find(steps);
    clumpstarts = [1; 1+clumpends];
    clumpends(end+1) = length(sv);
    clumpwidths = sv(clumpends) - sv(clumpstarts);
    clumpindex(pv) = clumpindex;
    
    clumpindex = clumpindex';
    clumpindex = reshape( clumpindex, sz );
    
    clumpcentres = zeros(1,length(clumpwidths));
    for i=1:length(clumpwidths)
        clumpcentres(i) = mean(sv(clumpstarts(i):clumpends(i)));
    end
end
