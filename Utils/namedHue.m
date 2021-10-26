function hue = namedHue( cname )
    hue = zeros( length(cname), 1 );
    for i=1:length(cname)
        switch cname(i)
            case 'r'
                hue(i) = 0;
            case 'g'
                hue(i) = 1/3;
            case 'b'
                hue(i) = 2/3;
            case 'c'
                hue(i) = 1/2;
            case 'm'
                hue(i) = 5/6;
            case 'y'
                hue(i) = 1/6;
            case 'o'
                hue(i) = 1/12;
            otherwise
                hue(i) = 0;
        end
    end
end
