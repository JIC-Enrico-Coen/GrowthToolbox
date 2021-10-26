function r = diffRect( r1, r2 )
%r = diffRect( r1, r2 )
%   r1 and r2 are rectangles represented as [ xlo, xhi, ylo, yhi ].
%   r is set to an array of disjoint rectangles whose union is r1 - r2. 
    
    XLO = 1;
    XHI = 2;
    YLO = 3;
    YHI = 4;
    
    % Eliminate the non-intersecting cases.
    if (r1(XLO) >= r2(XHI)) ...
            || (r1(XHI) <= r2(XLO)) ...
            || (r1(YLO) >= r2(YHI)) ...
            || (r1(YHI) <= r2(YLO))
        r = r1;
        return;
    end
    
    rightmostleft = max(r2(XHI),r1(XLO));
    leftmostright = min(r2(XLO),r1(XHI));
    upperlo = max(r2(YHI),r1(YLO));
    lowerhi = min(r2(YLO),r1(YHI));
    minYHI = min(r1(YHI),r2(YHI));
    maxYLO = max(r1(YLO),r2(YLO));
    
    % The result always consists of 4 rectangles, but some of them may be
    % empty.
    rr = [ rightmostleft, r1(XHI), maxYLO, minYHI ];
    rl = [ r1(XLO), leftmostright, maxYLO, minYHI ];
    rt = [ r1(XLO), r1(XHI), upperlo, r1(YHI) ];
    rb = [ r1(XLO), r1(XHI), r1(YLO), lowerhi ];
    
    % Return the non-empty rectangles.
    r = zeros( 0, 4 );
    nr = 0;
    if ~emptyrect(rr)
        nr = nr+1;
        r(nr,:) = rr;
    end
    if ~emptyrect(rl)
        nr = nr+1;
        r(nr,:) = rl;
    end
    if ~emptyrect(rt)
        nr = nr+1;
        r(nr,:) = rt;
    end
    if ~emptyrect(rb)
        nr = nr+1;
        r(nr,:) = rb;
    end
end

function emp = emptyrect( r )
    emp = (r(1) >= r(2)) || (r(3) >= r(4));
end
