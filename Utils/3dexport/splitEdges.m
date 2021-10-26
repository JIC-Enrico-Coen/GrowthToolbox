function [v1,f1] = splitEdges( v, f )
%[v1,f1] = splitEdges( v, f )
%   v is an N*K array.  f is an array of any size consisting of zero-based
%   indexes to the rows of v.  f may contain -1 elements.
%
%   f1 is the same shape as f and is -1 at the same places f is -1.  The
%   other elements are unique and index the rows of v1, in such a way than
%   v1(f1(i),:) = v(f(i),:) for all i for which f(i) is not -1.
%
%   The purpose of this is to transform Geometry information so as to split
%   apart all edges.

    if isempty( f )
        v1 = [];
        f1 = [];
    else
        isreal = f >= 0;
        fnotnan = f(isreal);
        v1 = v(fnotnan+1,:);
        f1 = f;
        f1(isreal) = 0:(length(fnotnan)-1);
    end
end
