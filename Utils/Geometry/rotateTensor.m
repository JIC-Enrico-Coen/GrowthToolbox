function t1 = rotateTensor( t0, r )
%t1 = rotateTensor( t0, r )
%   t0 is a tensor in 6-vector form, i.e. [ xx, yy, zz, yz, zx, xy ], or
%   3-vector form [xx yy xy].
%   r is a rotation matrix in 3 or 2 dimensions respectively.
%   The result is t rotated by r.
%   t may be a matrix of N row vectors, in which case t1 will also be.

    symmetrycount = 2;
    t1 = zeros(size(t0));
    for ti=1:size(t0,1)
        t = t0(ti,:);
        if size(t,2)==6
            if true
                tm = [ t(1), t(6)/symmetrycount, t(5)/symmetrycount;
                       t(6)/symmetrycount, t(2), t(4)/symmetrycount;
                       t(5)/symmetrycount, t(4)/symmetrycount, t(3) ];
                tm = r*tm*r';
                t1(ti,:) = [ tm(1,1), tm(2,2), tm(3,3), ...
                    tm(2,3)*symmetrycount, tm(3,1)*symmetrycount, tm(1,2)*symmetrycount ];
            else
                % This is slower.
                tm = [ t(1), t(6)/symmetrycount, t(5)/symmetrycount;
                       t(6)/symmetrycount, t(2), t(4)/symmetrycount;
                       t(5)/symmetrycount, t(4)/symmetrycount, t(3) ]; %#ok<UNRCH>
                tmr = r*tm;
                t1(ti,:) = sum( [ tmr(1,:).*r(1,:), ...
                             tmr(2,:).*r(2,:), ...
                             tmr(3,:).*r(3,:), ...
                             tmr(2,:).*r(3,:)*symmetrycount, ...
                             tmr(3,:).*r(1,:)*symmetrycount, ...
                             tmr(1,:).*r(2,:)*symmetrycount ], 2 )';
            end
        else
            tm = [ t(1), t(3)/symmetrycount;
                   t(3)/symmetrycount, t(2) ];
            tm = r*tm*r';
            t1(ti,:) = [ tm(1,1), tm(2,2), tm(1,2)*symmetrycount ];
        end
    end
end
