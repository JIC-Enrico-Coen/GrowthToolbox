function octagon( l )
%OCTAGON(L)  Draw a triangulated octagon.
%  L = radius of octagon.  The octagon is centred at the origin.
    clf;
    outeri = (0:1/8:1)*pi*2;
    outerx = cos(outeri)*l;
    outery = sin(outeri)*l;
    inneri = (0:1/4:1)*pi*2;
    innerx = cos(inneri)*l/2;
    innery = sin(inneri)*l/2;
    outerx1 = cycle( outerx, 1 );
    line(outerx,outery);
    line(innerx,innery);
    line( [ innerx(1:4); outerx(1:2:7) ], ...
          [ innery(1:4); outery(1:2:7) ] );
    outerxA = outerx(2:2:8);
    outeryA = outery(2:2:8);
    line( [ innerx(1:4); outerx(2:2:8)], ...
          [ innery(1:4); outery(2:2:8)] );
    line( [ innerx(1:4); cycle(outerx(2:2:8),-1)], ...
          [ innery(1:4); cycle(outery(2:2:8),-1)] );
    line( [ innerx(1), innerx(3) ], [ innery(1), innery(3) ] );
    axis equal;
end
