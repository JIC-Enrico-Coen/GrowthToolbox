function c = randcolor( n, hsv1, hsv2 )
%c = randcolor( n, hsv1, hsv2 )
%   Generate n random colors as an N*3 matrix of RGB values.
%   hsv1 and hsv2 are two colors in HSV space (hue, saturation, value).
%   The resulting colours will be distributed in the box of HSV space
%   bounded by these two colours.  Some attempt is made to make the
%   distribution uniform in psychological colour space.
%
%   Examples:
%
%   To get only red colours, with any saturation and value:
%       randcolor( numcolors, [0 0 0], [0 1 1] );
%
%   To get colours ranging from greenish to blueish, all fully bright and saturated:
%       randcolor( numcolors, [0.3 1 1], [0.7 1 1] );
%
%   To get monochrome grey:
%       randcolor( numcolors, [0 0 0], [0 0 1] );

    % Colours in the green-to-blue range are, for a given difference in
    % hue, more similar to each other than colours whose hue lies in the
    % rest of the spectrum.
    spread = 0.2;
    h = spreadHue( randInRange( n, unspreadHue( [hsv1(1) hsv2(1)], spread ) ), spread );
    
    % Colours low in saturation are closer to each other than those of high
    % saturation.
    s = sqrt( randInRange( n, [hsv1(2) hsv2(2)].^2 ) );

    % Colours low in value are closer to each other than those of high
    % value.
    v = randInRange( n, [hsv1(3) hsv2(3)].^3 ).^0.333333;
    
    c = HSVtoRGB( h, s, v );
end

function v = randInRange( n, r )
    switch length(r)
        case 0
            v = rand(n,1);
        case 1
            v = ones(n,1) * r;
        case 2
            v = rand(n,1) * (r(2)-r(1)) + r(1);
    end
end

