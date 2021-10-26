function [b,c] = othersOf3( a )
%bc = othersOf3( a )
%[b,c] = othersOf3( a )
%   If a is in the range 1..3, set bc or [b,c] to the successors of a.
%   a can be an array of any shape.

    b1 = mod(a,3)+1;
    c1 = mod(b1,3)+1;
    if nargout==2
        b = b1;  c = c1;
    else
        b = [b1 c1];
    end
end
