function camparams = rotateMatlabCamera( camparams, rotmat )
%camparams = rotateMatlabCamera( camparams, rotmat )
%   Rotate the camera, defined by its Matlab parameters, about its view
%   target by the given rotation.

    newcampos = (camparams.CameraPosition - camparams.CameraTarget) * rotmat + camparams.CameraTarget;
    newcamup = camparams.CameraUpVector * rotmat;
    
    camparams.CameraPosition = newcampos;
    camparams.CameraUpVector = newcamup;
end
