function n = splaynodes( n, a1, a2, a3, a4 )
% n is assumed to be a N*3 array of points, assumed to have x and y
% coordinates all lying in the sector whose vertex is at the origin and
% which is bounded by angles a1 and a2.  The points are rotated and
% transformed so as to lie in the sector bounded by angles a3 and a4.

    theta = atan2( n(:,2), n(:,1) ) - a1;
    theta = theta*((a4-a3)/(a2-a1)) + a3;
    lengths = zeros(size(n,1),1);
    for i=1:size(n,1)
        lengths(i) = norm( n(i,1:2) );
    end
    n(:,1:2) = [ cos(theta) .* lengths, sin(theta) .* lengths ];
end

    