function v = cameraRightVector( camparams )
%v = cameraRightVector( camparams )
%   Returns a unit vector in the direction that is projected to the
%   rightwards direction in the image plane.

    v = cross( camparams.CameraTarget - camparams.CameraPosition, camparams.CameraUpVector );
    v = v / norm(v);
end
