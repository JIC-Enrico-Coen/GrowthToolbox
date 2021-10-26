function axisRange = axisBoundsDialog(handles)
    v = performRSSSdialogFromFile( 'axisbounds.txt', [], struct('handles',handles), ...
            @(h)setGFtboxColourScheme( h, handles ));
    if isempty(v)
        axisRange = [];
    else
        axisRange = str2double( { v.xmin, v.xmax, v.ymin, v.ymax, v.zmin, v.zmax } );
    end
end

function initAxisBoundsDialog( h, handles, axisRange )
    setGFtboxColourScheme( h, handles );
    setAxisBoundsInAxisBoundsDialog( h, axisRange )
end