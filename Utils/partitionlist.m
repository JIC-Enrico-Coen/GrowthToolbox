function s = partitionlist( n )
%s = partitionlist( n )
%   Set s{i} equal to find(n==j), where j is the i'th smallest value
%   occurring in n.

    nn = length(n);
    [n,p] = sort(n(:));
    e = find(n(2:nn) ~= n(1:(nn-1)));
    extents = [ [1;(e+1)], [e;nn] ];
    for i=1:size(extents,1)
        s{i} = p(extents(i,1):extents(i,2));
    end
end
