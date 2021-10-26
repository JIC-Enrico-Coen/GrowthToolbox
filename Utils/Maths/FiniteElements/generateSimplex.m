function [v,e] = generateSimplex( d, n )
    v = (0:n)';
    for i=2:d
        v1 = repmat( 0:n, size(v,1), 1 );
        v = [ v1(:), repmat( v, n+1, 1 ) ];
    end
    v = v( sum(v,2) <= n, end:-1:1 );
    nv = size(v,1);
    diffs = zeros(nv,nv);
    for i=1:d
        diffs = diffs + abs( repmat( v(:,i), 1, nv ) - repmat( v(:,i)', nv, 1 ) );
    end
    d = find(diffs==1) - 1;
    e1 = floor(d/nv) + 1;
    e2 = mod(d,nv) + 1;
    e = unique( sort( [ e1, e2 ], 2 ), 'rows' )';
    d = find(diffs==2) - 1;
    e1 = floor(d/nv) + 1;
    e2 = mod(d,nv) + 1;
    diags = sum(v(e1,:),2) == sum(v(e2,:),2);
    e3 = unique( sort( [ e1(diags), e2(diags) ], 2 ), 'rows' )';
    e = [ e, e3 ]';
end
