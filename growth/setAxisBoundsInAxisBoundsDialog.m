function setAxisBoundsInAxisBoundsDialog( dialogH, axisRange )
    if isempty( axisRange )
        set( dialogH.xmin, 'String', '' );
        set( dialogH.xmax, 'String', '' );
        set( dialogH.ymin, 'String', '' );
        set( dialogH.ymax, 'String', '' );
        set( dialogH.zmin, 'String', '' );
        set( dialogH.zmax, 'String', '' );
    else
        set( dialogH.xmin, 'String', num2str( axisRange(1), 5 ) );
        set( dialogH.xmax, 'String', num2str( axisRange(2), 5 ) );
        set( dialogH.ymin, 'String', num2str( axisRange(3), 5 ) );
        set( dialogH.ymax, 'String', num2str( axisRange(4), 5 ) );
        set( dialogH.zmin, 'String', num2str( axisRange(5), 5 ) );
        set( dialogH.zmax, 'String', num2str( axisRange(6), 5 ) );
    end
end
