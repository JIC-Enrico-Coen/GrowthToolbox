function [vxs,weights] = subdivideedgePoints( m, ei, tension )
    if nargin < 3
        tension = 1/16;
    end

    p1 = m.edgeends( ei, 1 );
    p2 = m.edgeends( ei, 2 );
    [e3,p3] = nextborderedge( m, ei, p1 );
    [e4,p4] = nextborderedge( m, ei, p2 );
    if (p3==0) || (p4==0)
        weights = [0.5, 0.5];
        vxs = [p1 p2];
    else
        weights = [-tension, 0.5+tension, 0.5+tension, -tension];
        vxs = [p3 p1 p2 p4];
    end
end
