function t1 = rotateTensor( t0, r )
%t1 = rotateTensor( t0, r )
%   t0 is a tensor in 6-vector form, i.e. [ xx, yy, zz, yz, zx, xy ], or
%   3-vector form [xx yy xy].
%   r is a rotation matrix in 3 or 2 dimensions respectively.
%   The result is t rotated by r.
%   t may be an N*K matrix of N row vectors, in which case t1 will also be.
%
%   USED ONLY IN tensorsFromDisplacements AND getRealGrowth, WHICH ARE
%   NEVER USED.

    symmetrycount = 2;
    t1 = zeros(size(t0));
    for ti=1:size(t0,1)
        t = t0(ti,:);
        if size(t,2)==6
            tm = [ t(1), t(6)/symmetrycount, t(5)/symmetrycount;
                   t(6)/symmetrycount, t(2), t(4)/symmetrycount;
                   t(5)/symmetrycount, t(4)/symmetrycount, t(3) ];
            tm = r*tm*r';
            t1(ti,:) = [ tm(1,1), tm(2,2), tm(3,3), ...
                tm(2,3)*symmetrycount, tm(3,1)*symmetrycount, tm(1,2)*symmetrycount ];
        else
            tm = [ t(1), t(3)/symmetrycount;
                   t(3)/symmetrycount, t(2) ];
            tm = r*tm*r';
            t1(ti,:) = [ tm(1,1), tm(2,2), tm(1,2)*symmetrycount ];
        end
    end
end
