function tg = ttygrid( history )
    history.findCoords();
    g = history.makeGrid();
    sg = size(g);
    tg = zeros( sg(1:2) * 3 );
    for row=1:sg(1)
        for col=1:sg(2)
            trow = row*3;
            tcol = col*3;
            tg( trow-2:trow, tcol-2:tcol ) = ttycell( g(row,col,:) );
        end
    end
    tg = char(tg);
end

function result = ttycell( cdata )
    result = [ [ ' ', ' ', ' ' ]; [ ' ', ' ', ' ' ]; [ ' ', ' ', ' ' ] ];
    if cdata(5)
        result(2,2) = '*';
    elseif cdata(1)
        result(2,2) = 'O';
    elseif all( reshape( cdata(2:5), 1, 4 ) == [ 1, 0, 1, 0 ] )
        result(2,2) = '|';
    elseif any(cdata(2:5))
        result(2,2) = '+';
    end
    if cdata(2), result(1,2) = '|'; end
    if cdata(3), result(2,3) = '-'; end
    if cdata(4), result(3,2) = '|'; end
    if cdata(5), result(2,1) = '-'; end
end

