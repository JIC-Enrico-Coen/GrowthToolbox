function d = alldet( m )
%d = alldet( m )
%   Calculate the determinant of every page of m.

    sz = size(m);
    switch length(sz)
        case 2
            d = 0;
        case 3
            d = zeros( sz(3), 1 );
        otherwise
            d = zeros( sz(3:end) );
    end
    m = reshape( m, sz(1), sz(2), [] );
    for i=1:size(m,3)
        d(i) = det( m(:,:,i) );
    end
end
