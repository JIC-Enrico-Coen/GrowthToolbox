function camParams = autozoomcentre( camParams, bbox, zoom, centre )
%camParams = autozoomcentre( camParams, bbox, zoom, centre )
%   Adjust the camera params so as to look at the centre of the bbox (if
%   centre is true) and have the bbox fill the field of view (if zoom is
%   true).  bbox is a 6-element vector as returned by axis().

global gMatlabViewParams

    camposition = camParams.CameraPosition;
    camtarget = camParams.CameraTarget;
    if centre
        newcamtarget = (bbox([2 4 6]) + bbox([1 3 5]))/2;
        camParams.CameraTarget = newcamtarget;
        newposition = camposition + camParams.CameraTarget - camtarget;
    else
        newcamtarget = camParams.CameraTarget;
        newposition = camposition;
    end
    if zoom
        camerafromtarget = newposition - camParams.CameraTarget;
        axisdiam = norm(bbox([2 4 6]) - bbox([1 3 5]));
        camParams.CameraViewAngle = gMatlabViewParams.CameraViewAngle;
        cdist = axisdiam/(2*tan(camParams.CameraViewAngle*(pi/180)/2));
        targetdistance = norm(camerafromtarget);
        camParams.CameraPosition = (cdist/targetdistance)*camerafromtarget + newcamtarget;
    end
end
