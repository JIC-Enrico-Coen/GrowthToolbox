function cc = randcolornear( numcolors, color, colorvariation )
%crange = randcolornear( numcolors, color, colorvariation )
%   Generate NUMCOLORS random colors that are "near" the given COLOR.  If
%   COLORVARIATION is 0, they will be equal to COLOR, while if
%   COLORVARIATION is 1, they will be scattered over the whole colour
%   space.

    color = double(color);  % The conversion to double is needed because
        % under obscure circumstances, color has been observed to have type
        % single. But rgb2hsv requires its argument to have type double.
    colorvariation = double(colorvariation);
        % We also convert colorvariation to double, just to be on the safe side.

    h = rgb2hsv( color );
    crange = [ h-colorvariation; h+colorvariation ];
    crange(:,[2 3]) = trimnumber( 0, crange(:,[2 3]), 1 );
    crange(:,1) = crange(:,1) - floor(crange(:,1));
    crange(2,1) = normaliseNumber(crange(2,1), crange(1,1), crange(1,1)+1 );
    cc = randcolor( numcolors, crange(1,:), crange(2,:) );
end
