function rgb = namedColor( c )
% rgb = namedColor( cname )
% Convert a string of color names to a N*3 array of colors.
% Unrecognised color names are converted to grey.
% If the argument is numeric it is returned unchanged.

    if ischar(c)
        rgb = zeros( length(c), 3 );
        for i=1:length(c)
            switch c(i)
                case 'k'
                    rgb(i,:) = [0 0 0];
                case 'r'
                    rgb(i,:) = [1 0 0];
                case 'g'
                    rgb(i,:) = [0 1 0];
                case 'b'
                    rgb(i,:) = [0 0 1];
                case 'c'
                    rgb(i,:) = [0 1 1];
                case 'm'
                    rgb(i,:) = [1 0 1];
                case 'y'
                    rgb(i,:) = [1 1 0];
                case 'o'
                    rgb(i,:) = [1 0.5 0];
                case 'w'
                    rgb(i,:) = [1 1 1];
                otherwise
                    rgb(i,:) = [0.5 0.5 0.5];
            end
        end
    else
        rgb = c;
    end
end
