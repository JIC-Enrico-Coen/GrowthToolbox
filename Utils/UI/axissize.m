function [pixelwidth,realwidth] = axissize( theaxes )
    campos = get( theaxes,'CameraPosition' );
    camtgt = get( theaxes,'CameraTarget' );
    viewangle = get( theaxes,'CameraViewAngle' );
    realwidth = abs( norm(camtgt-campos) * tan( viewangle*(pi/180)/2 ) * 2 );
    axispos = get( theaxes, 'Position' );
    pixelwidth = min( axispos([3 4]) );
end
