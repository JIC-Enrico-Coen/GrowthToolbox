function [q,w] = basicQuadraturePoints( numsimplexdims, degree )
%[q,w] = basicQuadraturePoints( numsimplexdims, degree )
%   Return the quadrature points and weights for any simplex and any
%   degree, up to some bound.

    otherdeg2 = degree==2.5;  % Special case
    if otherdeg2
        degree = 2;
    end
    q = [];
    w = [];
    switch numsimplexdims
        case { 0, 1 }
            switch degree
                case { 0, 1 }
                    q = [];
                    w = 2;
                case 2
                    q = 1/sqrt(3);
                    w = 1;
                case 3
                    q = sqrt(0.6);
                    w = [ 8 5 ]/9;
                case 4
                    q = [ 0.339981043584856 0.861136311594053 ];
                    w = [ 0.652145154862546 0.347854845137454 ];
                case 5
                    q = [ 0.538469310105683 0.906179845938664 ];
                    w = [ 0.568888888000009 0.478628670499366 0.236926885056189 ];
                otherwise
                    if degree > 6
                        warning( '%s: box degree %d too large, reduced to 6.', mfilename(), degree );
                    end
                    q = [ 0.238619186083197 0.661209386466265 0.932469514203152 ];
                    w = [ 0.467913934572691 0.360761573048139 0.171324492379170 ];
            end
            if mod(degree,2)==0
                q = [ -q(end:-1:1) q ]';
                w = [ w(end:-1:1) w ];
            else
                q = [ -q(end:-1:1) 0 q ]';
                w = [ w(end:-1:2) w ];
            end
        case 2
            switch degree
                case 1
                    q = [ 1/3 1/3 ];
                    w = 1/2;
                case 2
                    if otherdeg2
                        q = [ 1/6 1/6; 2/3 1/6; 1/6 2/3 ];
                    else
                        q = [ 0.5 0; 0 0.5; 0.5 0.5 ];
                    end
                    w = [1 1 1]/6;
                case 3
                    q = [ 1/3 1/3; 0.6 0.2; 0.2 0.6; 0.2 0.2 ];
                    w = [ -27, 25*ones(1,3) ]/96;
                otherwise
                    if degree > 5
                        warning( '%s: simplex degree %d too large, reduced to 5.', mfilename(), degree );
                    end
                    c0 = 0.225;
                    a1 = 0.0597158717;
                    b1 = 0.4701420641;
                    c1 = 0.1323941527;
                    a2 = 0.7974269853;
                    b2 = 0.1012865073;
                    c2 = 0.1259391805;
                    quadbc = [
                        1/3 1/3 1/3;
                        a1 b1 b1;
                        b1 a1 b1;
                        b1 b1 a1;
                        a2 b2 b2;
                        b2 a2 b2;
                        b2 b2 a2 ];
                    q = quadbc(:,[1 2]);
                    w = [ c0 c1 c1 c1 c2 c2 c2 ]'/2;
            end
        case 3
            switch degree
                case 1
                    q = [ 1 1 1 ]/4;
                    w = 1;
                case 2
                    a = 0.58541020;
                    b = 0.13819660;
                    q = [ a b b; b a b; b b a; b b b ];
                    w = [1 1 1 1]/4;
                otherwise
                    if degree > 3
                        warning( '%s: simplex degree %d too large, reduced to 3.', mfilename(), degree );
                    end
                    a = 1/2;
                    b = 1/6;
                    c = 1/4;
                    q = [ c c c; a b b; b a b; b b a; b b b ];
                    w = [ -16 9 9 9 9]/60;
            end;
        otherwise
            warning( '%s: simplex dimension %d too large, no quadrature available.', mfilename(), numsimplexdims );
    end
    w = w(:);
end
