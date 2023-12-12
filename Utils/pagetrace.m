function t = pagetrace( m )
%t = PAGETRACE( m )
%   M is a matrix of any number of dimensions, whose sizes in its first two
%   dimensions are equal to some N.
%
%   The result is a matrix T of the traces of the N*N slices of M. The
%   shape of T is the remaining dimensions of M.
%
%   See also: pagetranspose

    sz = size( m );
    len = prod(sz(3:end));
    n = min(sz([1 2]));
    m = reshape( m, sz(1), sz(2), [] );
    t = zeros( len, 1 );
    for pi = 1:len
        t(pi) = trace( m(:,:,pi) );
    end
    if length(sz) < 4
        sz((end+1):4) = 1;
    end
    t = reshape( t, sz([3:end]) );
end
