function a = concatArrays( a1, a2, dim )
%a = concatArrays( a1, a2, dim )
%   A1 and A2 are arrays of the same shape. These are concatenated along
%   the dimension DIM. DIM can be larger than the number of dimensions of
%   the arrays.
%
%   If either array is empty, regardless of size, the other is returned. If
%   they are both nonempty but of different lengths along any dimension
%   other than DIM, an error is thrown.

    if isempty(a1)
        a = a2;
        return;
    end
    if isempty(a2)
        a = a1;
        return;
    end
    
    a1sz = size(a1);
    a2sz = size(a2);
    if dim > length(a1sz)
        a1sz( (end+1):dim ) = 1;
    end
    if dim > length(a2sz)
        a2sz( (end+1):dim ) = 1;
    end
    if length(a1sz) < length(a2sz)
        a1sz( (end+1):length(a2sz) ) = 1;
    end
    if length(a2sz) < length(a1sz)
        a2sz( (end+1):length(a12sz) ) = 1;
    end
    
    xx = find( a1sz ~= a2sz );
    if any(xx ~= dim)
        error( 'Array sizes are not compatible.' );
    end
    
    prelength = prod( a1sz(1:(dim-1)) );
    postlength = prod( a1sz((dim+1):end) );
    tempsize1 = [prelength a1sz(dim) postlength];
    tempsize2 = [prelength a2sz(dim) postlength];
    newsize = [ a1sz(1:(dim-1)) a1sz(dim)+a2sz(dim) a1sz((dim+1):end) ];
    a = reshape( [reshape( a1, tempsize1 ) reshape( a2, tempsize2 )], newsize );
end
