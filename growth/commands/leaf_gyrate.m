function m = leaf_gyrate( m, varargin )
%m = leaf_gyrate( m, ... )
%   Spin and/or tilt the mesh about the Z axis, leaving it at the end in
%   exactly the  same orientation as when it started.  If a movie is currently being
%   recorded, the animation will be appended to the movie.  The current view
%   is assumed to have already been written to the movie.
%
%   Options:
%       'frames':  The number of frames to be added.  Default 60.
%       'spin':    The number of rotations about the Z axis. Default 1.
%       'waveangle':    If NaN (the default) spinning is in complete
%                  revolutions.  If non-zero, spinning consists of turning
%                  right and left and back to centre.  The initial
%                  direction will be rightwards if waveangle is positive.
%       'tilt':    The number of cycles of tilting up, down, and back to
%                  the initial elevation. (Down then up if tiltangle is
%                  negative.) Default 1.
%       'tiltangle':  The angle to tilt up and down to, in degrees from the
%                     horizontal.  Default 90.
%       'rotaxis': Which axis to rotate about. This value is one of
%                  'xyzjdnrul'. x, y, and z refer to the global axes. j,
%                  d, and n refer to the major, middle, and minor axes of
%                  the mesh. 'r', 'u', and 'l' refer to the camera right,
%                  up, and look axes. The value can also be a number from 1
%                  to 9, representing the same axes respectively.
%       'tiltaxis': Which axis to tilt about. This has the same possible
%                   values as rotaxis. It must be different from rotaxis.
%                   By default, tilt axis is the axis following rotaxis in
%                   cyclic order, i.e. 'yzxdrjulr'. 
%                   If not supplied, its default value is the common
%                   perpendicular of the rotation axis and the camera-up
%                   vector, or if they are parallel, it is the camera-right
%                   vector.
%
%   Topics: Movies/Images, Plotting.

% fprintf( 1, '%s: starting\n', mfilename() );
    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'frames', 60, ...
            'spin', 1, ...
            'waveangle', NaN, ...
            'tilt', 1, ...
            'tiltangle', 90, ...
            'rotaxis', 'z', ...
            'tiltaxis', '' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'frames', 'spin', 'waveangle', 'tilt', 'tiltangle', 'rotaxis', 'tiltaxis' );
    if ~ok, return; end
    
    if isempty( m.pictures )
        fprintf( 1, '%s: no current picture -- cannot gyrate view.\n', mfilename() );
        return;
    end
    if ischar( s.rotaxis )
        rotaxisindex = find( lower(s.rotaxis)=='xyzjdnrul', 1 );
    else
        rotaxisindex = s.rotaxis;
    end
    if isempty(rotaxisindex)
        fprintf( 1, '%s: invalid rotation axis.\n', mfilename() );
        return;
    end
    
    s.frames = floor(s.frames);
    revsPerFrame = s.spin/s.frames;
    
    % All rotation of the camera is relative to its current parameters.
    initCamParams = getCameraParams( m.pictures(1) );
    
    [rotAxis,defaultTiltAxis1] = convertAxisIndexToAxisVector( rotaxisindex, m, initCamParams );
    
    defaultTiltAxis2 = cross( rotAxis, initCamParams.CameraUpVector );
    defaultTiltAxis2 = defaultTiltAxis2 / norm(defaultTiltAxis2);
    if any(isnan(defaultTiltAxis2))
        defaultTiltAxis2 = cameraRightVector( initCamParams );
    end
    
    defaultTiltAxis = defaultTiltAxis2;
    
    if isempty( s.tiltaxis )
        tiltaxisindex = 0;
        tiltAxis = defaultTiltAxis;
    else
        if ischar( s.tiltaxis )
            tiltaxisindex = find( lower(s.tiltaxis)=='xyzjdnrul', 1 );
        else
            tiltaxisindex = s.tiltaxis;
        end
        if tiltaxisindex==rotaxisindex
            tiltaxisindex = 0;
            tiltAxis = defaultTiltAxis;
        else
            tiltAxis = convertAxisIndexToAxisVector( tiltaxisindex );
        end
    end
    
    fprintf( 1, 'Gyrating viewpoint: %s, %s, spin angle %.2f, spin axis %d, tilt angle %.2f, tilt axis %d.\n', ...
        pluralString( s.frames, 'frame' ), ...
        pluralString( s.spin, 'cycle' ), ...
        s.waveangle, rotaxisindex, s.tiltangle, tiltaxisindex );
    
    if isnan( s.waveangle )
        az_vals = (pi/180) * normaliseAngle( (360*revsPerFrame)*(1:s.frames), -180 );
    else
        warp = (0.5 - 0.5*cos( (1:s.frames)*(pi/s.frames) ))*s.frames*(revsPerFrame*2*pi);
        offsets = sin(warp);
        az_vals = (pi/180) * normaliseAngle( s.waveangle*offsets, -180 );
    end
    if s.tiltangle==0
        el_vals = zeros( 1, s.frames );
    else
        el_vals = (pi/180) * saw( (1:s.frames)/s.frames, s.tilt, -s.tiltangle, s.tiltangle, 0, false );
    end

    for i=1:(s.frames-1)
        % rotationVectorToMatrix is in the Vision Toolbox. Replaced by our
        % own function axisAngle2RotMat. The commented-out code tests that
        % these return identical results, up to rounding error.
%         rotAxisMx1 = rotationVectorToMatrix( rotAxis * az_vals(i) );
%         tiltAxisMx1 = rotationVectorToMatrix( tiltAxis * -el_vals(i) ); % Is the minus sign something to do with the sense of the tilt axis?
        rotAxisMx2 = axisAngle2RotMat( rotAxis * az_vals(i) );
        tiltAxisMx2 = axisAngle2RotMat( tiltAxis * -el_vals(i) ); % Is the minus sign something to do with the sense of the tilt axis?
        rotAxisMx = rotAxisMx2;
        tiltAxisMx = tiltAxisMx2;
%         rotError = max( abs( [ rotAxisMx2(:)-rotAxisMx1(:); tiltAxisMx2(:)-tiltAxisMx1(:) ] ) );
%         fprintf( 2, 'rotation error %g\n', rotError );
        rotMx = tiltAxisMx * rotAxisMx;
        camParams = rotateMatlabCamera( initCamParams, rotMx );
        setMeshView( m, camParams );
        drawnow;
        m = recordframe( m );
    end
    
    setMeshView( m, initCamParams );
    drawnow;
    m = recordframe( m );
end


function [av,av1] = convertAxisIndexToAxisVector( ac, m, initCamParams )
% AC is a number from 1 to 9.
% 1-3 are mapped to the global X, Y, and Z axes.
% 4-6 are mapped to the mesh principal axes.
% 7-9 are mapped to the camera right, up, and look axes.

    if ac <= 3
        av = [0; 0; 0];
        av(ac) = 1;
        av1 = av( [3 1 2] );
    elseif ac <= 6
        if isVolumetricMesh(m)
            [principalAxes,eigs,~] = bestFitEllipsoid( m.FEnodes );
        else
            [principalAxes,eigs,~] = bestFitEllipsoid( m.nodes );
        end
        [~,perm] = sort(eigs,'descend');
        principalAxes = principalAxes(:,perm);
        ai = ac-3;
        av = principalAxes(:,ai);
        av1 = principalAxes(:,1+mod(ai,3));
    else
        [cameraLook, cameraUp, cameraRight] = cameraFrame( initCamParams );
        principalAxes = [ cameraRight; cameraUp; cameraLook ]';
        ai = ac-6;
        av = principalAxes(:,ai);
        av1 = principalAxes(:,1+mod(ai,3));
    end
end
