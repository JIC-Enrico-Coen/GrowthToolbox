function camParams = offsetCameraParams( camParams, eyeoffset )
%camParams = offsetCameraParams( camParams, eyeoffset )

    % get tgt-cam vector
    % rotate it about up vector
    % compute new cam pos
    % install it
    
    if eyeoffset ~= 0
        camvec = camParams.CameraPosition - camParams.CameraTarget;
        camright = cross( camvec, camParams.CameraUpVector );
        camright = camright*norm(camvec)/norm(camright);
        eyeoffsetRadians = eyeoffset*pi/180;
        s = sin(eyeoffsetRadians);
        c = cos(eyeoffsetRadians);
        camvec = c*camvec - s*camright;
        camParams.CameraTarget = camParams.CameraPosition - camvec;
    end
end
