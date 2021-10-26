function bc4 = squarebc( bc, d )
%bc4 = squarebc( bc, d )
%   Return the barycentric coordinates of a quadrilateral centred on bc with
%   radius d.

    r3 = 1/sqrt(3);
    bcxy = [ [ -1, 1, 0 ]; ...
             [ -r3, -r3, r3+r3 ] ];
    sq = ([ [-1 -1]; [1 -1]; [1 1]; [-1 1] ] * bcxy) * d;
    bc4 = normaliseBaryCoords( [bc;bc;bc;bc]+sq );
%    bc4 = [bc;bc;bc;bc]+sq;
end
    