function v = vorticity( x, u )
%v = vorticity( x, u )
%   Given N*3 matrices x and u of points and displacements respectively,
%   find the best-fit rigid rotation v.
%   EXPERIMENTAL CODE, DO NOT USE YET.

    avx = sum(x,1)/size(x,1)
    avu = sum(u,1)/size(u,1);
    x = x - repmat( avx, size(x,1), 1 );
  % u = u - repmat( avu, size(u,1), 1 );  % Answer is independent of any
                                          % offset to u.
    xu = sum( cross( x, u, 2 ), 1 )
    M = x'*x
    M2 = [ M(2,2)+M(3,3), -M(1,2), -M(1,3);
           -M(2,1), M(3,3)+M(1,1), -M(2,3);
           -M(3,1), -M(3,2), M(1,1)+M(2,2) ]
    detM2 = det(M2)
    v = xu*inv(M2);
    vv = repmat( v, size(x,1), 1 );
    rots = cross(vv,x,2)
    errs = rots - u
    sumerrs = sum(errs,1)
end
