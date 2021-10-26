function [v,perm] = makeloop( v1, v2, i )
%perm = makeloop( v1, v2, i )
%   v1 is a vector of distinct values and v2 is a permutation of v1
%   consisting of a single cycle.
%   perm is a permutation such that if w1 = v1(perm) and w2 = v2(perm),
%   then w1 = w2([2:end 1]).  perm begins with i; this makes it unique.
%   If i is omitted it defaults to 1.
%
%   If v2 consists of more than one cycle, then the cycle beginning at i
%   will be returned.
%
%   When v1 has the form 1:N, v and perm will be identical.

    if nargin < 3
        i = 1;
    end
    
    if isempty(v1)
        v = [];
        perm = [];
        return;
    end

    [p1,i1] = sort(v1);
    [p2,i2] = sort(v2);
    i2(i2) = (1:length(i2))';
    perm = zeros(1,length(v1),'int32');
    k = i;
    perm(1) = k;
    j = 1;
    while true
        k = i1(i2(k));
        if k==i
            break;
        end
        j = j+1;
        perm(j) = k;
    end
    perm((j+1):end) = [];
    v = v1(perm);
end
