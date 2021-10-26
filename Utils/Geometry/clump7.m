function [pts,cellvxs] = clump7( theta, d )
%[pts,cellvxs] = clump7( theta, d )
%   Create a rosette of 7 regular hexagons.
%   D is the diameter of each hexagon.
%   THETA is the angle through which the clump should be rotated from its
%   default orientation, in which the central hexagon has a vertex at (d/2,0).
%   PTS will be a 24x2 array of the vertexes.
%   CELLVXS will be a 7x6 array listing for each of the hexagon the indexes
%   of its vertexes in PTS.

    h = sqrt(3)/2;
    c1 = [ 1 0
          0.5 h
          -0.5 h
          -1 0
          -0.5 -h
          0.5 -h ] * (d/2);
    s = sin(theta);  c = cos(theta);
    c1 = c1 * [ [c s]; [-s c] ];
    c2 = c1*2;
    c3a = c2 + c1([2 3 4 5 6 1],:);
    c3b = c2 + c1([6 1 2 3 4 5],:);
    pts = [ c1; c2; c3a; c3b ];
    cellvxs = [ 1:6; [ 1:6; 7:12; 13:18; [20:24 19]; [8:12 7]; [2:6 1] ]' ];

    return;
    
    figure(1);
    cla;
    hold on;
    patch( pts(cellvxs(1,:),1), pts(cellvxs(1,:),2), 'r' );
    for i=2:7
        patch( pts(cellvxs(i,:),1), pts(cellvxs(i,:),2), 'c' );
    end
    plot( pts(:,1),pts(:,2),'o');
    axis equal
    axis square
    axis( [ -d d -d d ]*2 );
    hold off;
end
