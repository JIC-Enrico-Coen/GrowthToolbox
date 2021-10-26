function c = tripleProducts( a, d1, d2 )
%c = tripleProducts( a, b, d1, d2 )
%   Calculate the triple products of all corresponding slices of A and B
%   along dimensions D1 and D2.  A and B must have the same shape, and
%   their size in dimensions D1 and D2 must be 3.  C will have the shape
%   resulting from omitting dimension D2.

    if nargin < 2
        d1 = 1;
    end
    if nargin < 2
        d2 = d1+1;
    end
    p = 1:length(size(a));
    p([d1,d2]) = [];
    p = [d1, d2, p];
    aa = reshape( permute( a, p ), 3, 3, [] );
    c = dot( a(1,:,:), cross( a(2,:,:), a(3,:,:), 2 ), 2 );
    sza = size(a);
    c = reshape( c, sza(p(3:end)) );
end
