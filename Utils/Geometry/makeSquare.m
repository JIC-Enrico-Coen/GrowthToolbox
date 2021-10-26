function r = makeSquare( r )
%r = makeSquare( r )
%   r is a 4-element array [x y w h] such as is used to represent
%   rectangles in GUIs.  This procedure trims r to be square, and centres
%   the new square within the old rectangle.

    d = min(r([3 4]));
    r = [ r(1)+(r(3)-d)/2, r(2)+(r(4)-d)/2, d, d ];
end
