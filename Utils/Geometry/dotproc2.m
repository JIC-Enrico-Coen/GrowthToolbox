function d = dotproc2( v1, v2 )
%d = dotproc1( v1, v2 )
%   Equivalent to dot(v1,v2,2) where v1 and v2 are two-dimensional matrices
%   of the same size.
%
%   See also DOTPROC1, CROSSPROC1, CROSSPROC2.

    d = zeros( size(v1,1), 1 );
    for i=1:size(v1,2)
        d = d + v1(:,i).*v2(:,i);
    end
end
