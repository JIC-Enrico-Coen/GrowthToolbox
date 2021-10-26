function r1 = placeRectInRect( r, r1, margins, glue )
%r1 = foo( r, r1, mode )
%   r and r1 are positions (both of the form [x,y,w,h]).
%   margins is a list of 4 numbers [ml, mb, mr, mt].
%   glue is an array of compass directions, each of which is n, w, s, or e.
%   The result is a rectangle obtained by first insetting r by the margins
%   to produce a frame rectangle, then attaching the sides of r1 to the
%   sides of the frame wherever the corresponding compass point appears in
%   the glue string.  Where a side is unglued, r1 retains its dimension
%   (width or height) in that direction.

    frame = [ r([1 2]) + margins([1 2]), ...
              r([3 4]) - margins([1 2]) - margins([3 4]) ];
    top = false;
    bottom = false;
    left = false;
    right = false;
    for i=1:length(glue)
        switch glue(i)
            case 'w'
                left = true;
            case 'e'
                right = true;
            case 's'
                bottom = true;
            case 'n'
                top = true;
        end
    end
    if right
        if left
            r1([1 3]) = frame([1 3]);
        else
            r1(1) = frame(1) + frame(3) - r1(3);
        end
    elseif left
        r1(1) = frame(1);
    else
        r1(1) = frame(1) + (frame(3) - r1(3))/2;
    end
    if top
        if bottom
            r1([2 4]) = frame([2 4]);
        else
            r1(2) = frame(2) + frame(4) - r1(4);
        end
    elseif bottom
        r1(2) = frame(2);
    else
        r1(2) = frame(2) + (frame(4) - r1(4))/2;
    end
end
