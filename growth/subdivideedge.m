function [pos,prismpos] = subdivideedge( m, ei, tension, bc )
%[pos,prismpos] = subdivideedge( m, ei, tension, bc )
%   Find the subdivision point on a border edge ei as defined by the
%   butterfly method.
%
%   NOT USED.  See subdivideedgePoints.

    if nargin < 3
        tension = 1/16;
    end
    if nargin < 4
        bc = [0.5 0.5];
    end
    [wts,pts] = edgesplinewts( m, ei, tension, bc );
    pos = wts * m.nodes(pts,:);
    prismpos = [wts * m.prismnodes(pts*2-1,:);
                wts * m.prismnodes(pts*2,:)];
end
