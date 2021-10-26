function setaxis( theaxes, axisrange, centre )
%setaxis( theaxes, axisrange, centre )
%   This works like axis, but assumes that the camera is on manual mode,
%   and does the automatic camera ranging.  If centre is true (the default)
%   then the view will be adjusted to pass through the centre of the axis
%   box.

    if nargin < 3
        centre = true;
    end

    oldaxisrange = [ get( theaxes, 'XLim' ) get( theaxes, 'YLim' ) get( theaxes, 'ZLim' ) ];
    oldaxissize = max( oldaxisrange([2,4,6]) - oldaxisrange([1 3 5]) );
    if length(axisrange)==4
        axisrange([5 6]) = oldaxisrange( [5 6] );
    end
    for i=1:2:5
        j = i+1;
        if axisrange(i) >= axisrange(j)
            axisrange([i j]) = oldaxisrange( [i j] );
        end
    end
    if any(isnan(axisrange([1 2])))
        axisrange([1 2]) = get( theaxes, 'XLim' );
    end
    if any(isnan(axisrange([3 4])))
        axisrange([3 4]) = get( theaxes, 'YLim' );
    end
    if any(isnan(axisrange([5 6])))
        axisrange([5 6]) = get( theaxes, 'ZLim' );
    end
    set( theaxes, 'XLim', axisrange([1 2]), 'YLim', axisrange([3 4]), 'ZLim', axisrange([5 6]) );
    if centre
        cp = getCameraParams( theaxes );
        % Put the view direction through the centre of the axis box.
        if length(axisrange)==4
            axislower = [ axisrange([1,3]), 0 ];
            axisupper = [ axisrange([2,4]), 0 ];
        else
            axislower = axisrange([1,3,5]);
            axisupper = axisrange([2,4,6]);
        end
        axiscentre = (axisupper + axislower)/2;
        newaxissize = max( axisupper - axislower );
        if oldaxissize==0
            viewscale = 1;
        else
            viewscale = newaxissize/oldaxissize;
        end
        % Find the perpendicular from axiscentre to the view line
        lookcentre = nearestPointOnLine( [cp.CameraPosition;cp.CameraTarget], axiscentre );
        relativecamtarget = cp.CameraTarget - lookcentre;
        relativecampos = cp.CameraPosition - lookcentre;
        cp.CameraTarget = axiscentre + relativecamtarget*viewscale;
        cp.CameraPosition = axiscentre + relativecampos*viewscale;
        setCameraParams( theaxes, cp );
    end
end
