function matlabViewParams = rectifyFOV_MVP( matlabViewParams, newfov )
%matlabViewParams = rectifyFOV_MVP( matlabViewParams, newfov )
%   Set the field of view angle, and change the camera distance so that in
%   orthographic projection, the visible appearance of the scene is
%   unchanged.  This computation is carried out in terms of Matlab's view
%   parameters.
%   newfov is given in degrees.

    oldfov = matlabViewParams.CameraViewAngle;
    matlabViewParams.CameraViewAngle = newfov;
    cameraoffset = matlabViewParams.CameraPosition - matlabViewParams.CameraTarget;
    newcameraoffset = cameraoffset * tan(oldfov*pi/360)/tan(newfov*pi/360);
    matlabViewParams.CameraPosition = matlabViewParams.CameraTarget + newcameraoffset;
end
