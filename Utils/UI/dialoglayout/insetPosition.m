function pos = insetPosition( pos, inset )
%pos = insetPosition( pos, inset )
%   POS is an array [x y w h].  INSET is an array [left right top bottom].
%   The result is a position which is inset from the given position by the
%   given amount on each edge.

    pos = [ pos(1) + inset(1), ...
            pos(2) + inset(2), ...
            pos(3) - inset(1) - inset(3), ...
            pos(4) - inset(2) - inset(4) ];
end
