function [wts,pts] = edgesplinewts( m, ei, tension, bc )
% [wts,pts] = edgesplinewts( m, ei, tension, bc )
%   Find the points in the butterfly stencil for a border edge ei,
%   and the corresponding weights.

    if nargin < 3
        tension = 1/16;
    end
    if nargin < 4
        bc = [0.5 0.5];
    end
    
    p1 = m.edgeends( ei, 1 );
    p2 = m.edgeends( ei, 2 );
    
    if tension==0
        wts = bc;
        pts = [p1 p2];
    else 
        [~,p3] = nextborderedge( m, ei, p1 );
        [~,p4] = nextborderedge( m, ei, p2 );
        if (p3==0) || (p4==0)
            wts = bc;
            pts = [p1 p2];
        else
            wts = [0 bc 0] + tension*[-1 1 1 -1];
            pts = [p3 p1 p2 p4];
        end
    end
end
