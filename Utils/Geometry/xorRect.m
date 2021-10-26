function r = xorRect( r1, r2 )
%r = xorRect( r1, r2 )
%   r1 and r2 are rectangles represented as [ xlo, xhi, ylo, yhi ].
%   r is set to an array of disjoint rectangles whose union is the
%   symmetric difference of r1 and r2.

    r = [ diffRect(r1,r2); diffRect(r2,r1) ];
end
        
