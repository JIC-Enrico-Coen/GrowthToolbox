function [p1,w1] = uniqueweights( p, w )
%[p,w] = uniqueweights( p, w )
%   p and w are both N-element vectors.  p will typically be a set of
%   indexes into an array.  w is a vector of weights.  The result p
%   contains the unique elements of p in the same order, and the result w
%   sums together the elements of the  original w that correspond to equal
%   values of p.

    [p1,~,ic] = unique(p,'stable');
    w1 = zeros(size(p1));
    for i=1:length(w)
        w1(ic(i)) = w1(ic(i)) + w(i);
    end
end