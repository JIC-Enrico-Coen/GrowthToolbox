function c = mixcolors( colors, opacity, positive, mode, weight )
    if nargin < 5
        weight = 0;
    end
    if nargin < 4
        mode = 0;
    end
    if nargin < 3
        positive = true;
    end
    switch mode
        case 'hard'
            if positive
                c = max( colors, [], 1 );
            else
                c = min( colors, [], 1 );
            end
        case 'mult'
            if positive
                c = 1-prod( 1-colors, 1 );
            else
                c = prod( colors, 1 );
            end
        case 'av'
            numlayers = sum(opacity);
            if numlayers==0
                c = [1 1 1];
                return;
            end
            c = (opacity(:)'*colors)/numlayers;
          % c = sum( colors, 1 )/size( colors, 1 );
            if numlayers < 1
                numlayers = 1;
            end
            w = (1+weight)^(numlayers-1);
            if positive
                c = 1 - (1-c)/w;
            else
                c = c/w;
            end
    end
    t = prod(1-opacity);
    c = [1 1 1]*t + c*(1-t);
end
