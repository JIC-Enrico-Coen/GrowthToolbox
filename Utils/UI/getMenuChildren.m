function c = getMenuChildren( h )
%c = getMenuChildren( h )
%   Return a list of the children of h in the same order they appear in the
%   menu.

    c = get( h, 'Children' );
    if length(c) > 1
        p = get( c, 'Position' );
        pp = [ p{:} ];
        c(pp) = c;
    end
end
