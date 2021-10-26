function r1 = rectInRect( r, where, pos )
%r1 = rectInRect( r, where, pos )
%   POS is an array [insetx, insety, width, height].  Set r1 to be a
%   rectangle of size [width height], inset by insetx and insety from the
%   edges of R indicated by WHERE, which is a string being one of 'n', 's',
%   'w', 'e', 'ne', 'ne, 'sw', 'se', 'c'.  x and y are assumed to increase
%   to the right and up.

    switch where
        case {'n' 'nw' 'ne'}
            y = r(2)+r(4)-pos(2)-pos(4);
        case {'s', 'sw', 'se'}
            y = r(2)+pos(2);
        otherwise
            y = r(2) + (r(4)+pos(4))/2;
    end
    switch where
        case {'w' 'nw' 'sw'}
            x = r(1)+pos(1);
        case {'e', 'ne', 'se'}
            x = r(1)+r(3)-pos(1)-pos(3);
        otherwise
            x = r(1) + (r(3)+pos(1))/2;
    end
    r1 = [ x y pos([3 4])];
end
