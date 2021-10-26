function ip = invperm( p )
%ip = invperm( p )
%   Find the inverse of a permutation P. P can be an array of any shape,
%   but will be treated as one-dimensional. IP will have the same shape as
%   P.  IP(P) and P(IP) will both be identical to
%   reshape( 1:numel(P), size(P) ).

    ip(p) = 1:numel(p);
    ip = reshape( ip, size(p) );
end
