function setViewFromMesh( m, except )
    if isempty(m)
        return;
    end
    if nargin < 2
        except = -1;
    end
    for i=1:length(m.pictures)
        f = m.pictures(i);
        if f == except, continue; end
        if ~ishandle(f), continue; end
        h = guidata( f );
        if ~isfield( h, 'picture' ), continue; end
        if ~ishandle( h.picture ), continue; end
        if isfield( h, 'stereooffset' ) && (h.stereooffset ~= 0)
            eyeParams = offsetCameraParams( m.plotdefaults.matlabViewParams, h.stereooffset );
            setCameraParams( h.picture, eyeParams );
        else
            setCameraParams( h.picture, m.plotdefaults.matlabViewParams );
        end
        if isfield( h, 'azimuth' ) && ishandle( h.azimuth )
            set( h.azimuth, 'Value', ...
                normaliseAngle( -m.plotdefaults.ourViewParams.azimuth, -180, true ) );
        end
        if isfield( h, 'elevation' ) && ishandle( h.elevation )
            set( h.elevation, 'Value', ...
                normaliseAngle( -m.plotdefaults.ourViewParams.elevation, -180, true ) );
        end
        if isfield( h, 'roll' ) && ishandle( h.roll )
            set( h.roll, 'Value', ...
                normaliseAngle( -m.plotdefaults.ourViewParams.roll, -180, true ) );
        end
    end

    setscalebarsize( m );
end
