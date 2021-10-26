function axisrange = axisrangeFromDialog( handles )
    axisrange = [];
    if ~isfield( handles, 'mesh' ), return; end
    if isempty( handles.mesh ), return; end
    
    [ xlo, ok1 ] = getDoubleFromDialog( handles.xaxislo );
    [ xhi, ok2 ] = getDoubleFromDialog( handles.xaxishi );
    [ ylo, ok3 ] = getDoubleFromDialog( handles.yaxislo );
    [ yhi, ok4 ] = getDoubleFromDialog( handles.yaxishi );
    [ zlo, ok5 ] = getDoubleFromDialog( handles.zaxislo );
    [ zhi, ok6 ] = getDoubleFromDialog( handles.zaxishi );

    if ~(ok1 && ok2 && ok3 && ok4 && ok5 && ok6)
        return;
    end

    if isempty( handles.mesh )
        [xlo,xhi] = rectifyrange( xlo, xhi, [-1 1] );
        [ylo,yhi] = rectifyrange( ylo, yhi, [-1 1] );
        [zlo,zhi] = rectifyrange( zlo, zhi, [-1 1] );
    else
        [xlo,xhi] = rectifyrange( xlo, xhi, handles.mesh.prismnodes( :, 1 ) );
        [ylo,yhi] = rectifyrange( ylo, yhi, handles.mesh.prismnodes( :, 2 ) );
        [zlo,zhi] = rectifyrange( zlo, zhi, handles.mesh.prismnodes( :, 3 ) );
    end

    axisrange = [ xlo, xhi, ylo, yhi, zlo, zhi ];
end

function [lo,hi] = rectifyrange( lo, hi, v )
    if lo >= hi
        if isempty(v)
            lo = -1; hi = 1;
        else
            lo = min( v );
            hi = max( v );
            mid = (lo+hi)/2;
            lo = lo + 0.1*(lo-mid);
            hi = hi + 0.1*(hi-mid);
        end
    end
end
