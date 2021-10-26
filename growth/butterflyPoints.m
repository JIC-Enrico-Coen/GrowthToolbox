function [pts,wts] = butterflyPoints( m, ei, tension )
%[pts,wts] = butterflyPoints( m, ei, tension )
%   Find the points and weights associated with subdividing edge ei by
%   the butterfly algorithm.

    if nargin < 3
        tension = 1/16;
    end

    wts = [ 1/2 1/2 tension*2 tension*2 -tension -tension -tension -tension ];

    p1 = m.edgeends( ei, 1 );
    p2 = m.edgeends( ei, 2 );
    c1 = m.edgecells( ei, 1 );
    c2 = m.edgecells( ei, 2 );
    
    if c2==0
        [pts,wts] = subdivideedgePoints( m, ei, tension );
        return;
    end
    
    p3 = othervertex( m, c1, p1, p2 );

    e11 = m.celledges( c1, m.tricellvxs(c1,:)==p2 );
    c11 = othercell( m, c1, e11 );
    if c11 == 0
        p5 = 0;
        corr5 = wts(5) * [ 1 -1 1 0 -1 0 0 0 ];
    else
        p5 = m.tricellvxs( c11, m.celledges(c11,:)==e11 );
        corr5 = zeros(1,8);
    end

    e12 = m.celledges( c1, m.tricellvxs(c1,:)==p1 );
    c12 = othercell( m, c1, e12 );
    if c12 == 0
        p6 = 0;
        corr6 = wts(6) * [ -1 1 1 0 0 -1 0 0 ];
    else
        p6 = m.tricellvxs( c12, m.celledges(c12,:)==e12 );
        corr6 = zeros(1,8);
    end
    
    p4 = othervertex( m, c2, p1, p2 );

    e21 = m.celledges( c2, m.tricellvxs(c2,:)==p2 );
    c21 = othercell( m, c2, e21 );
    if c21 == 0
        p7 = 0;
        corr7 = wts(7) * [ 1 -1 0 1 0 0 -1 0 ];
    else
        p7 = m.tricellvxs( c21, m.celledges(c21,:)==e21 );
        corr7 = zeros(1,8);
    end

    e22 = m.celledges( c2, m.tricellvxs(c2,:)==p1 );
    c22 = othercell( m, c2, e22 );
    if c22==0
        corr8 = wts(8) * [ -1 1 0 1 0 0 0 -1 ];
        p8 = 0;
    else
        corr8 = zeros(1,8);
        p8 = m.tricellvxs( c22, m.celledges(c22,:)==e22 );
    end
    
    wts = wts + corr5 + corr6 + corr7 + corr8;
    pts = [ p1 p2 p3 p4 p5 p6 p7 p8 ];
    pts = pts( wts ~= 0 );
    wts = wts( wts ~= 0 );
end
