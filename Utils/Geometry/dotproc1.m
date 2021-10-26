function d = dotproc1( v1, v2 )
%d = dotproc1( v1, v2 )
%   Equivalent to dot(v1,v2,1) where v1 and v2 are two-dimensional matrices
%   of the same size.
%
%   See also DOTPROC2, CROSSPROC1, CROSSPROC2.

    d = zeros( 1, size(v1,2) );
    for i=1:size(v1,1)
        d = d + v1(i,:).*v2(i,:);
    end
end
